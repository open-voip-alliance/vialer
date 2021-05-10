import 'package:flutter/material.dart';

import '../../../util/brand.dart';

class StylizedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? labelText;
  final bool hasError;
  final bool autoCorrect;
  final TextCapitalization textCapitalization;
  final List<String> autofillHints;

  StylizedTextField({
    Key? key,
    this.labelText,
    this.prefixIcon,
    this.suffix,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.hasError = false,
    this.autoCorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints = const [],
  }) : super(key: key);

  static const color = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 4,
      child: TextField(
        controller: controller,
        autocorrect: autoCorrect,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            color: hasError ? context.brand.theme.errorContentColor : color,
            size: 16,
          ),
          suffixIcon: suffix,
          labelText: labelText,
          border: inputBorder,
          enabledBorder: inputBorder,
          disabledBorder: inputBorder,
          focusedBorder: inputBorder,
          labelStyle: const TextStyle(
            color: color,
          ),
          focusColor: color,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: const TextStyle(
          color: Colors.black,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
      ),
    );
  }

  final InputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: const BorderSide(
      style: BorderStyle.none,
      width: 0,
    ),
  );
}
