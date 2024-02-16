import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:vialer/presentation/util/context_extensions.dart';

import 'package:vialer/presentation/resources/theme.dart';

class StylizedTextField extends StatelessWidget {
  StylizedTextField({
    super.key,
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
    this.onSubmitted,
    this.enabled = true,
    this.elevation = 4,
    this.bordered = false,
    this.semanticsLabel,
    this.textInputAction = TextInputAction.next,
  });

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
  final void Function(String)? onSubmitted;
  final bool enabled;
  final double elevation;
  final bool bordered;
  final String? semanticsLabel;
  final TextInputAction textInputAction;

  static const color = Colors.grey;

  @override
  Widget build(BuildContext context) {
    final inputBorder = !bordered
        ? noInputBorder
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: context.brand.theme.colors.grey2,
            ),
          );

    Widget textField = TextField(
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
                    hasError ? context.brand.theme.colors.errorContent : color,
                size: 16,
              )
            : prefixWidget,
        suffixIcon: suffix,
        labelText: labelText,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: inputBorder,
        labelStyle: const TextStyle(color: color),
        focusColor: color,
        filled: true,
        fillColor: Colors.white,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: hintText,
      ),
      style: textStyle,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      onTap: onTap,
      onSubmitted: onSubmitted,
    );

    textField = context.hasKeyboardDismissAsParent
        ? IgnoreKeyboardDismiss(child: textField)
        : textField;

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      child: Semantics(
        textField: true,
        value: semanticsLabel,
        child: textField,
      ),
    );
  }

  final InputBorder noInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide.none,
  );
}
