import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';

class Keypad extends StatefulWidget {
  final TextEditingController controller;
  final BoxConstraints? constraints;
  final bool canDelete;
  final Widget primaryButton;
  final Widget? secondaryButton;
  final VoidCallback? onDeleteAll;

  const Keypad({
    Key? key,
    required this.controller,
    this.constraints,
    this.canDelete = true,
    required this.primaryButton,
    this.secondaryButton,
    this.onDeleteAll,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> {
  /// This is necessary to keep track of because if the cursor has been shown
  /// once in a readOnly text field, the cursor will be shown forever, even if
  /// the offset is reported as -1. We need to update the position of the
  /// cursor in that case.
  final _cursorShownNotifier = ValueNotifier<bool>(false);

  final _buttonValues = {
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
        constraints: widget.constraints,
        bottomPadding: bottomPadding,
        // Because of the iOS design, we want a slimmer keypad. On Android
        // we have a wider keypad, as to follow native dialers there.
        slim: context.isIOS,
      ),
      childrenDelegate: SliverChildListDelegate.fixed(
        [
          ..._buttonValues.entries.map(
            (entry) => KeypadValueButton._(
              controller: widget.controller,
              cursorShownNotifier: _cursorShownNotifier,
              primaryValue: entry.key,
              secondaryValue: entry.value,
              replaceWithSecondaryValueOnLongPress:
                  entry.key == '0' && entry.value == '+',
            ),
          ),
          widget.secondaryButton ?? const SizedBox(),
          Center(
            child: widget.primaryButton,
          ),
          _DeleteButton(
            controller: widget.controller,
            cursorShownNotifier: _cursorShownNotifier,
            canDelete: widget.canDelete,
            onDeleteAll: widget.onDeleteAll,
          ),
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
            ? BorderSide(color: context.brand.theme.grey3)
            : BorderSide.none,
      ),
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: child,
      ),
    );
  }
}

class KeypadValueButton extends StatefulWidget {
  static const maxSize = 80.0;

  final String primaryValue;
  final String? secondaryValue;

  final bool replaceWithSecondaryValueOnLongPress;

  /// Controller to push text to on press.
  final TextEditingController controller;

  final ValueNotifier<bool> cursorShownNotifier;

  const KeypadValueButton._({
    Key? key,
    required this.primaryValue,
    this.secondaryValue,
    this.replaceWithSecondaryValueOnLongPress = false,
    required this.controller,
    required this.cursorShownNotifier,
  })   : assert(
          !replaceWithSecondaryValueOnLongPress || secondaryValue != null,
        ),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _KeypadValueButtonState();
}

class _KeypadValueButtonState extends State<KeypadValueButton> {
  TextEditingController get _controller => widget.controller;

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
  }

  bool get _primaryIsNumber => int.tryParse(widget.primaryValue) != null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: KeypadValueButton.maxSize,
          maxHeight: KeypadValueButton.maxSize,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return KeypadButton(
              child: _InkWellOrResponse(
                isResponse: !context.isIOS,
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
                            ? context.brand.theme.grey5
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
                        color: context.brand.theme.grey5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;
  final bool canDelete;
  final VoidCallback? onDeleteAll;

  const _DeleteButton({
    Key? key,
    required this.controller,
    required this.cursorShownNotifier,
    this.canDelete = true,
    this.onDeleteAll,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  TextEditingController get _controller => widget.controller;

  bool __canDelete = false;

  bool get _canDelete => widget.canDelete && __canDelete;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_handleStatusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStatusChange);

    super.dispose();
  }

  void _handleStatusChange() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        __canDelete = true;
      });
    } else {
      setState(() {
        __canDelete = false;
      });
    }
  }

  void _delete() {
    if (_controller.text.isNotEmpty) {
      final baseOffset = _controller.selection.baseOffset;
      final extentOffset = _controller.selection.extentOffset;

      if (baseOffset == 0 && extentOffset == 0) {
        return;
      }

      final hasOffset = baseOffset >= 0 && extentOffset >= 0;

      final text = _controller.text;

      final cursorShown = widget.cursorShownNotifier.value;

      String start, end;
      if (hasOffset) {
        start = text.substring(
          0,
          baseOffset == extentOffset ? baseOffset - 1 : baseOffset,
        );
        end = text.substring(extentOffset);
      } else {
        start = text.substring(0, text.length - 1);
        end = '';
      }

      widget.controller.value = _controller.value.copyWith(
        text: start + end,
        selection: TextSelection.collapsed(
          offset: hasOffset || cursorShown
              ? baseOffset == extentOffset
                  ? baseOffset - 1
                  : baseOffset
              : -1,
        ),
      );
    }
  }

  void _deleteAll() {
    _controller.clear();
    widget.onDeleteAll?.call();
  }

  @override
  Widget build(BuildContext context) {
    return KeypadButton(
      borderOnIos: false,
      child: InkResponse(
        onTap: _canDelete ? _delete : null,
        onLongPress: _canDelete ? _deleteAll : null,
        child: AnimatedTheme(
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: _canDelete
                      ? context.brand.theme.grey5
                      : context.brand.theme.grey2,
                ),
          ),
          child: const Icon(
            VialerSans.correct,
            size: 32,
          ),
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

  final bool isResponse;

  const _InkWellOrResponse({
    Key? key,
    required this.onTapDown,
    this.onLongPress,
    this.isResponse = false,
    this.customBorder,
    this.enableFeedback = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // onTap needs to be defined for onTapDown to work
    void onTap() {}
    void onTapDown(_) => this.onTapDown();

    return isResponse
        ? InkResponse(
            enableFeedback: enableFeedback,
            onTap: onTap,
            onTapDown: onTapDown,
            onLongPress: onLongPress,
            customBorder: customBorder,
            child: child,
          )
        : InkWell(
            enableFeedback: enableFeedback,
            onTap: onTap,
            onTapDown: onTapDown,
            onLongPress: onLongPress,
            customBorder: customBorder,
            child: child,
          );
  }
}
