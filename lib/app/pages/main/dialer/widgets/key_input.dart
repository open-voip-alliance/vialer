import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyInput extends StatelessWidget {
  final TextEditingController controller;

  const KeyInput({Key key, @required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // This is needed so that the keyboard doesn't popup. We can't use
      // readOnly because then pasting is not allowed.
      focusNode: _NeverFocusNode(),
      inputFormatters: [_KeyInputFormatter()],
      showCursor: true,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
      ),
    );
  }
}

class _NeverFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

/// Removes all characters not generally allowed in a phone number.
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
