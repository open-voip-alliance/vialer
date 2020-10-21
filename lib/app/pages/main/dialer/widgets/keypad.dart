import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../resources/theme.dart';

class Keypad extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onCallButtonPressed;

  const Keypad({
    Key key,
    this.controller,
    this.onCallButtonPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> {
  TextEditingController _controller;

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
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    const bottomPadding = 32.0;

    return GridView.custom(
      padding: const EdgeInsets.only(bottom: bottomPadding),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: _KeypadGridDelegate(
        bottomPadding: bottomPadding,
        // Because of the iOS design, we want a slimmer keypad. On Android we
        // have a wider keypad, as to follow native dialers there.
        slim: context.isIOS,
      ),
      childrenDelegate: SliverChildListDelegate.fixed(
        [
          ..._buttonValues.entries.map(
            (entry) => ValueButton(
              controller: _controller,
              cursorShownNotifier: _cursorShownNotifier,
              primaryValue: entry.key,
              secondaryValue: entry.value,
              replaceWithSecondaryValueOnLongPress:
                  entry.key == '0' && entry.value == '+',
            ),
          ),
          const SizedBox(), // Empty space in the grid.
          _CallButton(
            onPressed: widget.onCallButtonPressed,
          ),
          _DeleteButton(
            controller: _controller,
            cursorShownNotifier: _cursorShownNotifier,
          ),
        ],
      ),
    );
  }
}

class _KeypadGridDelegate extends SliverGridDelegate {
  final double bottomPadding;

  /// Whether the keypad should be slimmed down, meaning it will be less
  /// wide.
  final bool slim;

  _KeypadGridDelegate({this.bottomPadding = 0, this.slim = false});

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const itemsPerRow = 3;
    const itemsPerColumn = 5;

    const maxCrossAxisExtent = 164.0;
    final maxMainAxisExtent = slim ? 104.0 : 96.0;

    var crossAxisExtent = min(
      constraints.crossAxisExtent / itemsPerRow,
      maxCrossAxisExtent,
    );

    final height = constraints.viewportMainAxisExtent - bottomPadding;

    var mainAxisExtent = min(
      height / itemsPerColumn,
      maxMainAxisExtent,
    );

    if (slim) {
      // We use the smallest extent, and we use the same extent for the cross
      // and main axis, so the children will have square constraints.
      final smallestExtent = min(crossAxisExtent, mainAxisExtent);

      crossAxisExtent = smallestExtent;
      mainAxisExtent = smallestExtent;
    }

    // Stride will be the extent, without padding (possibly) substracted.
    final crossAxisStride = crossAxisExtent;
    final mainAxisStride = mainAxisExtent;

    const padding = 4;

    // We add some padding between items if the buttons are smaller than the
    // max size, because in that case there will be no extra space between them.
    if (crossAxisExtent < ValueButton.maxSize) {
      crossAxisExtent -= padding;
    }

    if (mainAxisExtent < ValueButton.maxSize) {
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

  _CenteredSliverGridRegularTileLayout({
    this.constraints,
    int crossAxisCount,
    double mainAxisStride,
    double crossAxisStride,
    double childMainAxisExtent,
    double childCrossAxisExtent,
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

class _KeypadButton extends StatelessWidget {
  final bool borderOnIos;

  final Widget child;

  const _KeypadButton({
    Key key,
    this.borderOnIos = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: borderOnIos && context.isIOS
            ? BorderSide(color: context.brandTheme.grey3)
            : BorderSide.none,
      ),
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: child,
      ),
    );
  }
}

@visibleForTesting
class ValueButton extends StatefulWidget {
  static const maxSize = 80.0;

  final String primaryValue;
  final String secondaryValue;

  final bool replaceWithSecondaryValueOnLongPress;

  /// Controller to push text to on press.
  final TextEditingController controller;

  final ValueNotifier<bool> cursorShownNotifier;

  const ValueButton({
    Key key,
    @required this.primaryValue,
    this.secondaryValue,
    this.replaceWithSecondaryValueOnLongPress = false,
    @required this.controller,
    @required this.cursorShownNotifier,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ValueButtonState();
}

class _ValueButtonState extends State<ValueButton> {
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
      text: start + widget.secondaryValue + end,
    );
  }

  bool get _primaryIsNumber => int.tryParse(widget.primaryValue) != null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ValueButton.maxSize,
          maxHeight: ValueButton.maxSize,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _KeypadButton(
              child: _InkWellOrResponse(
                isResponse: !context.isIOS,
                customBorder: CircleBorder(),
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
                            ? context.brandTheme.grey5
                            : null, // Null means default color
                      ),
                      // The font size is based on the available space, and we
                      // never make the font size bigger
                      textScaleFactor: min(
                        constraints.maxWidth / ValueButton.maxSize,
                        MediaQuery.textScaleFactorOf(context),
                      ),
                    ),
                    Text(
                      // Render an empty string if there's no secondary value
                      // to keep the alignments proper.
                      widget.secondaryValue ?? '',
                      style: TextStyle(
                        color: context.brandTheme.grey5,
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

class _CallButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CallButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On iOS we want the call button to be the same size as the
    // other buttons. Even though we set the max size as the min size,
    // a ConstrainedBox will never impose impossible constraints, so it's not
    // a problem. In this case, it basically means: 'Biggest size possible, but
    // with a certain limit'.
    final minSize = context.isIOS ? ValueButton.maxSize : 64.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: FloatingActionButton(
          backgroundColor: onPressed != null
              ? context.brandTheme.green1
              : context.brandTheme.grey1,
          onPressed: onPressed,
          child: Icon(VialerSans.phone, size: 32),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;

  const _DeleteButton({
    Key key,
    @required this.cursorShownNotifier,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  TextEditingController get _controller => widget.controller;

  bool _visible = false;

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
        _visible = true;
      });
    } else {
      setState(() {
        _visible = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate,
      child: _KeypadButton(
        borderOnIos: false,
        child: InkResponse(
          onTap: _visible ? _delete : null,
          onLongPress: _visible ? _deleteAll : null,
          child: Icon(
            VialerSans.correct,
            color: context.brandTheme.grey5,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _InkWellOrResponse extends StatelessWidget {
  final Widget child;
  final VoidCallback onTapDown;
  final VoidCallback onLongPress;
  final bool enableFeedback;
  final ShapeBorder customBorder;

  final bool isResponse;

  const _InkWellOrResponse({
    Key key,
    this.onTapDown,
    this.onLongPress,
    this.isResponse = false,
    this.customBorder,
    this.enableFeedback,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // onTap needs to be defined for onTapDown to work
    final onTap = this.onTapDown != null ? () {} : null;
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
