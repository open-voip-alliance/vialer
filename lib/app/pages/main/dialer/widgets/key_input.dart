import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyInput extends StatelessWidget {
  final TextEditingController controller;

  const KeyInput({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: _NeverFocusNode(),
      inputFormatters: [_KeyInputFormatter()],
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

class _NeverFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _KeyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.replaceAll(RegExp(r'[^0-9^+^,^;^(^)^.^-]'), ''),
    );
  }
}
