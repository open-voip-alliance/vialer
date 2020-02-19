import 'package:flutter/material.dart';

class KeyInput extends StatelessWidget {
  final TextEditingController controller;

  const KeyInput({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: _NoFocusNode(),
      showCursor: true,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
      ),
    );
  }
}

class _NoFocusNode extends FocusNode {
  @override
  bool get canRequestFocus => false;
}