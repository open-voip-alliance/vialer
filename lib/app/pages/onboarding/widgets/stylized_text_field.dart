import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../util/brand.dart';

class StylizedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffix;
  final String? labelText;
  final String? hintText;
  final bool hasError;
  final bool autoCorrect;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final List<TextInputFormatter> inputFormatters;
  final TextAlign textAlign;
  final TextStyle textStyle;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final bool enabled;
  final double elevation;

  StylizedTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffix,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.hasError = false,
    this.autoCorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters = const [],
    this.textAlign = TextAlign.start,
    this.textStyle = const TextStyle(
      color: Colors.black,
    ),
    this.onEditingComplete,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.elevation = 4,
  }) : super(key: key);

  static const color = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: elevation,
      child: TextField(
        textAlign: textAlign,
        inputFormatters: inputFormatters,
        controller: controller,
        focusNode: focusNode,
        autocorrect: autoCorrect,
        textCapitalization: textCapitalization,
        enabled: enabled,
        decoration: InputDecoration(
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color:
                      hasError ? context.brand.theme.errorContentColor : color,
                  size: 16,
                )
              : prefixWidget != null
                  ? prefixWidget
                  : null,
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintText: hintText,
        ),
        style: textStyle,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        autofillHints: autofillHints,
        onEditingComplete: onEditingComplete,
        onChanged: onChanged,
        onTap: onTap,
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
