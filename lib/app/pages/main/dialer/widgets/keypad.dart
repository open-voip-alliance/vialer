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

class _ValueButton extends StatelessWidget {
  final String primaryValue;
  final String secondaryValue;

  final bool replaceWithSecondaryValueOnLongPress;

  /// Controller to push text to on press.
  final TextEditingController controller;

  void _enterValue() {
    final offset = controller.selection.baseOffset;
    if (offset != -1) {
      final currentText = controller.text;

      final start = currentText.substring(0, offset);
      final end = currentText.substring(offset);

      controller.text = start + primaryValue + end;
    } else {
      controller.text += primaryValue;
    }
  }

  void _replaceWithSecondaryValue() {
    var offset = controller.selection.baseOffset;

    if (offset < 0) {
      offset = controller.text.length - 1;
    }

    final currentText = controller.text;

    final start = currentText.substring(0, offset);
    final end = currentText.substring(offset + 1);

    controller.text = start + secondaryValue + end;
  }

  bool get _primaryIsNumber => int.tryParse(primaryValue) != null;

  const _ValueButton({
    Key key,
    this.primaryValue,
    this.secondaryValue,
    this.controller,
    this.replaceWithSecondaryValueOnLongPress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _KeypadButton(
      child: Material(
        shape: CircleBorder(
          side: context.isIOS
              ? BorderSide(color: VialerColors.grey3)
              : BorderSide.none,
        ),
        child: _InkWellOrResponse(
          isResponse: !context.isIOS,
          customBorder: CircleBorder(),
          enableFeedback: true,
          onTapDown: _enterValue,
          onLongPress: replaceWithSecondaryValueOnLongPress
              ? _replaceWithSecondaryValue
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                primaryValue,
                style: TextStyle(
                  fontSize: 32,
                  color: !_primaryIsNumber
                      ? VialerColors.grey5
                      : null, // Null means default color
                ),
              ),
              // Render an empty string on non-iOS platforms
              // to keep the alignments proper
              if (secondaryValue != null || !context.isIOS)
                Text(
                  secondaryValue ?? '',
                  style: TextStyle(
                    color: VialerColors.grey5,
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
            backgroundColor: VialerColors.green1,
            onPressed: onPressed,
            child: Icon(VialerSans.phone, size: 32),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final TextEditingController controller;

  const _DeleteButton({Key key, this.controller}) : super(key: key);

  void _deletePrevious() {
    if (controller != null && controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final text = controller.text;
        controller.text = text.substring(0, text.length - 1);
      });
    }
  }

  void _deleteAll() {
    if (controller != null) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _KeypadButton(
      child: InkResponse(
        onTap: _deletePrevious,
        onLongPress: _deleteAll,
        child: Icon(
          VialerSans.correct,
          color: VialerColors.grey5,
          size: 32,
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
