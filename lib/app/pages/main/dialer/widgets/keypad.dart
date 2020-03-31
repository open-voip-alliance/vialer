import 'package:flutter/material.dart';
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
    '5': 'JKl',
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
    var rows = <Widget>[];

    final amountPerRow = 3;
    for (var i = 0; i < (_buttonValues.length / amountPerRow); i++) {
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _buttonValues.entries
              .skip(i * amountPerRow)
              .take(amountPerRow)
              .map((entry) {
            return _ValueButton(
              controller: _controller,
              cursorShownNotifier: _cursorShownNotifier,
              primaryValue: entry.key,
              secondaryValue: entry.value,
              replaceWithSecondaryValueOnLongPress:
                  entry.key == '0' && entry.value == '+',
            );
          }).toList(),
        ),
      );
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox.fromSize(
            size: _KeypadButton.size(context),
          ),
          // Empty space in the grid
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

    final buttonSize = _KeypadButton.size(context);

    rows = rows
        .map(
          (r) => SizedBox(
            width: (buttonSize.width * amountPerRow),
            child: r,
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: 32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rows,
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final Widget child;

  static const _baseSize = Size(82, 82);

  static EdgeInsets padding(BuildContext context) =>
      EdgeInsets.all(_relative(context, 12));

  static Size baseSize(BuildContext context) =>
      _relativeSize(context, _baseSize);

  static double _relative(BuildContext context, double input) {
    final screenSize = MediaQuery.of(context).size;

    final dimension =
        (input * (screenSize.width / 390)).clamp(input * 0.5, input);

    return dimension;
  }

  static Size _relativeSize(BuildContext context, Size size) {
    final dimension = _relative(context, size.width);

    return Size(dimension, dimension);
  }

  static Size size(BuildContext context) =>
      baseSize(context) +
      Offset(
        padding(context).horizontal,
        padding(context).vertical,
      );

  const _KeypadButton({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding(context),
      child: SizedBox.fromSize(
        size: baseSize(context),
        child: child,
      ),
    );
  }
}

class _ValueButton extends StatefulWidget {
  final String primaryValue;
  final String secondaryValue;

  final bool replaceWithSecondaryValueOnLongPress;

  /// Controller to push text to on press.
  final TextEditingController controller;

  final ValueNotifier<bool> cursorShownNotifier;

  const _ValueButton({
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

class _ValueButtonState extends State<_ValueButton> {
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
    return _KeypadButton(
      child: Material(
        shape: CircleBorder(
          side: context.isIOS
              ? BorderSide(color: context.brandTheme.grey3)
              : BorderSide.none,
        ),
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
              ),
              // Render an empty string on non-iOS platforms
              // to keep the alignments proper
              if (widget.secondaryValue != null || !context.isIOS)
                Text(
                  widget.secondaryValue ?? '',
                  style: TextStyle(
                    color: context.brandTheme.grey5,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
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
    return SizedBox.fromSize(
      size: _KeypadButton.size(context),
      child: Center(
        child: SizedBox.fromSize(
          size: _KeypadButton.size(context) * 0.70,
          child: FloatingActionButton(
            backgroundColor: context.brandTheme.green1,
            onPressed: onPressed,
            child: Icon(VialerSans.phone, size: 32),
          ),
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

    _controller.addListener(() {
      if (_controller.text.isNotEmpty) {
        setState(() {
          _visible = true;
        });
      } else {
        setState(() {
          _visible = false;
        });
      }
    });
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
              ? baseOffset == extentOffset ? baseOffset - 1 : baseOffset
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
