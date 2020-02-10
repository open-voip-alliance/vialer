import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vialer_lite/resources/theme.dart';

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
    return GridView.count(
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 3,
      padding: EdgeInsets.only(
        bottom: 24,
      ),
      childAspectRatio: 32 / 24,
      children: [
        ..._buttonValues.entries
            .map<Widget>(
              (entry) => _KeypadButton(
                controller: _controller,
                primaryValue: entry.key,
                secondaryValue: entry.value,
                replaceWithSecondaryValueOnLongPress:
                    entry.key == '0' && entry.value == '+',
              ),
            )
            .toList(),
        Container(), // Empty space in the grid
        _CallButton(onPressed: widget.onCallButtonPressed),
        _DeleteButton(controller: _controller),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
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
    int offset = controller.selection.baseOffset;

    if (offset < 0) {
      offset = controller.text.length - 1;
    }

    final currentText = controller.text;

    final start = currentText.substring(0, offset);
    final end = currentText.substring(offset + 1);

    controller.text = start + secondaryValue + end;
  }

  bool get _primaryIsNumber => int.tryParse(primaryValue) != null;

  const _KeypadButton({
    Key key,
    this.primaryValue,
    this.secondaryValue,
    this.controller,
    this.replaceWithSecondaryValueOnLongPress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      enableFeedback: true,
      onTapDown: (_) => _enterValue(),
      // onTap needs to be defined for onTapDown to work
      onTap: () {},
      onLongPress: replaceWithSecondaryValueOnLongPress
          ? _replaceWithSecondaryValue
          : null,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _CallButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CallButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          backgroundColor: VialerColors.green,
          onPressed: onPressed,
          child: Icon(VialerSans.phone, size: 32),
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
    return InkResponse(
      onTap: _deletePrevious,
      onLongPress: _deleteAll,
      child: Icon(
        VialerSans.correct,
        color: VialerColors.grey5,
        size: 32,
      ),
    );
  }
}
