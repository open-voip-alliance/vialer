import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/pigeon.dart';

class Keypad extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;
  final BoxConstraints? constraints;

  /// The button on the bottom left.
  final Widget? bottomLeftButton;

  /// The button on the bottom center.
  final Widget bottomCenterButton;

  /// The button on the button right.
  final Widget? bottomRightButton;

  const Keypad({
    Key? key,
    required this.controller,
    required this.cursorShownNotifier,
    this.constraints,
    this.bottomLeftButton,
    required this.bottomCenterButton,
    this.bottomRightButton,
  }) : super(key: key);

  static const _buttonValues = {
    '1': null,
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '*': null,
    '0': '+',
    '#': null,
  };

  @override
  Widget build(BuildContext context) {
    const bottomPadding = 32.0;

    return GridView.custom(
      padding: const EdgeInsets.only(bottom: bottomPadding),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: _KeypadGridDelegate(
        constraints: constraints,
        bottomPadding: bottomPadding,
        // Because of the iOS design, we want a slimmer keypad. On Android
        // we have a wider keypad, as to follow native dialers there.
        slim: context.isIOS,
      ),
      childrenDelegate: SliverChildListDelegate.fixed(
        [
          ..._buttonValues.entries.map(
            (entry) => KeypadValueButton._(
              controller: controller,
              cursorShownNotifier: cursorShownNotifier,
              primaryValue: entry.key,
              secondaryValue: entry.value,
              // In English, the screen reader will pronounce 'A B C' as
              // 'A bc' ('A beesee'). 'ABC' however, is correctly pronounced.
              // For other letters it would pronounce it as a word, so there
              // the spaces are necessary. This is only true for English, in
              // Dutch the screen reader will pronounce 'A B C' correctly, and
              // will pronounce 'ABC' like a word ('abk').
              separateSecondaryValueLettersForSemantics:
                  entry.value != 'ABC' || !context.isEnglish,
              replaceWithSecondaryValueOnLongPress:
                  entry.key == '0' && entry.value == '+',
            ),
          ),
          bottomLeftButton ?? const SizedBox(),
          Center(
            child: bottomCenterButton,
          ),
          bottomRightButton ?? const SizedBox(),
        ],
      ),
    );
  }
}

class _KeypadGridDelegate extends SliverGridDelegate {
  final BoxConstraints? constraints;
  final double bottomPadding;

  /// Whether the keypad should be slimmed down, meaning it will be less
  /// wide.
  final bool slim;

  _KeypadGridDelegate({
    this.constraints,
    this.bottomPadding = 0,
    this.slim = false,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final boxConstraints = this.constraints;

    const itemsPerRow = 3;
    const itemsPerColumn = 5;

    final maxCrossAxisExtent = slim ? 96.0 : 164.0;
    final maxMainAxisExtent = slim ? 104.0 : 96.0;

    var crossAxisExtent = min(
      constraints.crossAxisExtent / itemsPerRow,
      maxCrossAxisExtent,
    );

    final maxHeight =
        boxConstraints?.maxHeight ?? constraints.viewportMainAxisExtent;
    final height = maxHeight - bottomPadding;

    var mainAxisExtent = min(
      height / itemsPerColumn,
      maxMainAxisExtent,
    );

    // Stride will be the extent, without padding (possibly) subtracted.
    final crossAxisStride = crossAxisExtent;
    final mainAxisStride = mainAxisExtent;

    const padding = 8;

    // We add some padding between items if the buttons are smaller than the
    // max size, because in that case there will be no extra space between them.
    if (crossAxisExtent < KeypadValueButton.maxSize) {
      crossAxisExtent -= padding;
    }

    if (mainAxisExtent < KeypadValueButton.maxSize) {
      mainAxisExtent -= padding;
    }

    return _CenteredSliverGridRegularTileLayout(
      constraints: constraints,
      childCrossAxisExtent: crossAxisExtent,
      childMainAxisExtent: mainAxisExtent,
      crossAxisCount: itemsPerRow,
      crossAxisStride: crossAxisStride,
      mainAxisStride: mainAxisStride,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(covariant _KeypadGridDelegate oldDelegate) {
    return oldDelegate.bottomPadding != bottomPadding ||
        oldDelegate.slim != slim;
  }
}

class _CenteredSliverGridRegularTileLayout extends SliverGridRegularTileLayout {
  final SliverConstraints constraints;

  const _CenteredSliverGridRegularTileLayout({
    required this.constraints,
    required int crossAxisCount,
    required double mainAxisStride,
    required double crossAxisStride,
    required double childMainAxisExtent,
    required double childCrossAxisExtent,
    bool reverseCrossAxis = false,
  }) : super(
          crossAxisCount: crossAxisCount,
          mainAxisStride: mainAxisStride,
          crossAxisStride: crossAxisStride,
          childMainAxisExtent: childMainAxisExtent,
          childCrossAxisExtent: childCrossAxisExtent,
          reverseCrossAxis: reverseCrossAxis,
        );

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final geometry = super.getGeometryForChildIndex(index);

    // This is needed so the items as a whole are centered.
    final width = crossAxisStride * crossAxisCount;
    final maxWidth = constraints.crossAxisExtent;
    final padding = (maxWidth - width) / 2;

    return SliverGridGeometry(
      scrollOffset: geometry.scrollOffset,
      crossAxisExtent: geometry.crossAxisExtent,
      crossAxisOffset: geometry.crossAxisOffset + padding,
      mainAxisExtent: geometry.mainAxisExtent,
    );
  }
}

class KeypadButton extends StatelessWidget {
  final bool borderOnIos;

  final Widget child;

  const KeypadButton({
    Key? key,
    this.borderOnIos = true,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: borderOnIos && context.isIOS
            ? BorderSide(color: context.brand.theme.colors.grey3)
            : BorderSide.none,
      ),
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: MergeSemantics(
          child: Semantics(
            // This has no effect until this issue in Flutter is fixed:
            // https://github.com/flutter/flutter/issues/90498
            keyboardKey: true,
            child: child,
          ),
        ),
      ),
    );
  }
}

class KeypadValueButton extends StatefulWidget {
  static const maxSize = 80.0;

  final String primaryValue;
  final String? secondaryValue;

  final bool replaceWithSecondaryValueOnLongPress;

  /// Whether spaces should be added between the letters
  /// (e.g. 'MNO' -> 'M N O'). This is necessary because otherwise the
  /// screen reader will try to pronounce the letters as words.
  ///
  /// Note that this is not the case for every value in every language e.g.
  /// in English, it should be 'ABC' and not 'A B C' for correct pronunciation.
  final bool separateSecondaryValueLettersForSemantics;

  /// Controller to push text to on press.
  final TextEditingController controller;

  final ValueNotifier<bool> cursorShownNotifier;

  /// When enabled will play the relevant audio tone when the keypad button
  /// is pressed.
  final bool playTone;

  const KeypadValueButton._({
    Key? key,
    required this.primaryValue,
    this.secondaryValue,
    this.separateSecondaryValueLettersForSemantics = true,
    this.replaceWithSecondaryValueOnLongPress = false,
    required this.controller,
    required this.cursorShownNotifier,
    // ignore: unused_element
    this.playTone = true,
  })  : assert(
          !replaceWithSecondaryValueOnLongPress || secondaryValue != null,
        ),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _KeypadValueButtonState();
}

class _KeypadValueButtonState extends State<KeypadValueButton> {
  TextEditingController get _controller => widget.controller;
  final tones = Tones();

  @override
  void initState() {
    super.initState();
  }

  void _enterValue() {
    final baseOffset = _controller.selection.baseOffset;
    final extentOffset = _controller.selection.extentOffset;

    final hasOffset = baseOffset >= 0 && extentOffset >= 0;

    final text = _controller.text;

    String start, end;
    if (hasOffset) {
      start = text.substring(0, baseOffset);
      end = text.substring(extentOffset);
    } else {
      start = text;
      end = '';
    }

    final cursorShown = widget.cursorShownNotifier.value;

    _controller.value = _controller.value.copyWith(
      text: start + widget.primaryValue + end,
      selection: TextSelection.collapsed(
        offset: hasOffset || cursorShown
            ? start.length + widget.primaryValue.length
            : -1,
      ),
    );

    if (hasOffset) {
      widget.cursorShownNotifier.value = true;
    }

    if (context.isAndroid ||
        (context.isIOS && widget.replaceWithSecondaryValueOnLongPress)) {
      SemanticsService.announce(
        widget.primaryValue,
        Directionality.of(context),
      );
    }

    if (widget.playTone) {
      tones.playForDigit(widget.primaryValue);
    }
  }

  void _replaceWithSecondaryValue() {
    final offset = _controller.selection.extentOffset;

    final text = _controller.text;

    final hasOffset = offset >= 0;

    final start = text.substring(0, hasOffset ? offset - 1 : text.length - 1);
    final end = hasOffset ? text.substring(offset) : '';

    _controller.value = _controller.value.copyWith(
      text: start + widget.secondaryValue! + end,
    );

    SemanticsService.announce(
      context.msg.main.dialer.button.value
          .replacedWithHint(widget.secondaryValue!),
      Directionality.of(context),
    );
  }

  bool get _primaryIsNumber => int.tryParse(widget.primaryValue) != null;

  @override
  Widget build(BuildContext context) {
    final secondaryValueSemanticsLabel =
        widget.separateSecondaryValueLettersForSemantics
            ? widget.secondaryValue?.characters
                .mapIndexed(
                  (index, char) => index != 0 ? ' $char' : char,
                )
                .join()
            : widget.secondaryValue;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: KeypadValueButton.maxSize,
          maxHeight: KeypadValueButton.maxSize,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return KeypadButton(
              child: Semantics(
                label: widget.primaryValue,
                hint: secondaryValueSemanticsLabel,
                child: _InkWellOrResponse(
                  response: !context.isIOS,
                  customBorder: const CircleBorder(),
                  enableFeedback: true,
                  onTapDown: _enterValue,
                  onLongPress: widget.replaceWithSecondaryValueOnLongPress
                      ? _replaceWithSecondaryValue
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.primaryValue,
                        style: TextStyle(
                          fontSize: 32,
                          color: !_primaryIsNumber
                              ? context.brand.theme.colors.grey5
                              : null, // Null means default color
                        ),
                        // The font size is based on the available space, and we
                        // never make the font size bigger
                        textScaleFactor: min(
                          constraints.maxWidth / KeypadValueButton.maxSize,
                          MediaQuery.textScaleFactorOf(context),
                        ),
                      ),
                      Text(
                        // Render an empty string if there's no secondary value
                        // to keep the alignments proper.
                        widget.secondaryValue ?? '',
                        style: TextStyle(
                          color: context.brand.theme.colors.grey5,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InkWellOrResponse extends StatelessWidget {
  final Widget? child;
  final VoidCallback onTapDown;
  final VoidCallback? onLongPress;
  final bool enableFeedback;
  final ShapeBorder? customBorder;
  final bool response;

  /// Note that the [InkResponse] or [InkWell] and all its children are
  /// excluded from semantics. Only [onTapDown] and [onLongPress] are set for
  /// semantics.
  const _InkWellOrResponse({
    Key? key,
    required this.onTapDown,
    this.onLongPress,
    this.response = false,
    this.customBorder,
    this.enableFeedback = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // onTap needs to be defined for onTapDown to work.
    void onTap() {}
    void onTapDownWithDetails(_) => onTapDown();
    const excludeFromSemantics = true;

    return Semantics(
      onTap: onTapDown,
      onLongPress: onLongPress,
      child: ExcludeSemantics(
        child: response
            ? InkResponse(
                excludeFromSemantics: excludeFromSemantics,
                enableFeedback: enableFeedback,
                onTap: onTap,
                onTapDown: onTapDownWithDetails,
                onLongPress: onLongPress,
                customBorder: customBorder,
                child: child,
              )
            : InkWell(
                excludeFromSemantics: excludeFromSemantics,
                enableFeedback: enableFeedback,
                onTap: onTap,
                onTapDown: onTapDownWithDetails,
                onLongPress: onLongPress,
                customBorder: customBorder,
                child: child,
              ),
      ),
    );
  }
}
