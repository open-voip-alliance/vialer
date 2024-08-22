import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/onboarding/widgets/mobile_number/country_field/widget.dart';
import 'package:vialer/presentation/resources/theme.dart';

class SharedContactFieldRow extends StatelessWidget {
  const SharedContactFieldRow({
    this.icon,
    required this.hintText,
    required this.validator,
    required this.onValueChanged,
    this.isForPhoneNumber = false,
    this.isDeletable = false,
    this.onDelete,
    required this.initialValue,
    this.controller,
  });

  final IconData? icon;
  final String hintText;
  final String? Function(String?) validator;
  final void Function(String) onValueChanged;
  final void Function()? onDelete;
  final String? initialValue;
  final bool isForPhoneNumber;
  final bool isDeletable;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48.0,
                alignment: Alignment.center,
                child: FaIcon(
                  icon,
                  color: context.brand.theme.colors.grey1,
                  size: 20,
                ),
              ),
              Expanded(
                child: _SharedContactTextFormField(
                  hintText: hintText,
                  validator: validator,
                  onValueChanged: onValueChanged,
                  initialValue: initialValue,
                  isForPhoneNumber: isForPhoneNumber,
                  controller: controller,
                ),
              ),
              if (isDeletable)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 48.0,
                        child: OutlinedButton(
                          onPressed: () => onDelete!(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: BorderSide(
                              width: 1,
                              color: context.brand.theme.colors.primary
                                  .withOpacity(0.12),
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.trashCan,
                            color: context.brand.theme.colors.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                width: 16.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
      ],
    );
  }
}

class _SharedContactTextFormField extends StatefulWidget {
  const _SharedContactTextFormField({
    required this.hintText,
    required this.validator,
    required this.onValueChanged,
    required this.initialValue,
    this.isForPhoneNumber = false,
    this.controller,
  });

  final String hintText;
  final String? Function(String?) validator;
  final void Function(String) onValueChanged;
  final String? initialValue;
  final bool isForPhoneNumber;
  final TextEditingController? controller;

  @override
  State<_SharedContactTextFormField> createState() =>
      _SharedContactTextFormFieldState();
}

class _SharedContactTextFormFieldState
    extends State<_SharedContactTextFormField> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? this.controller;

    if (widget.initialValue.isNotNullOrBlank) {
      controller.text = widget.initialValue!;
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            validator: widget.validator,
            onChanged: (value) => widget.onValueChanged(value),
            textInputAction: TextInputAction.next,
            controller: controller,
            focusNode: focusNode,
            keyboardType: widget.isForPhoneNumber
                ? Platform.isIOS
                    ? TextInputType.numberWithOptions(signed: true)
                    : TextInputType.phone
                : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: widget.isForPhoneNumber
                  ? CountryFlagField(
                      controller: controller,
                      focusNode: focusNode,
                      initialValue: widget.initialValue,
                    )
                  : null,
              hintText: !widget.isForPhoneNumber ? widget.hintText : null,
              hintStyle: TextStyle(color: context.brand.theme.colors.grey5),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: context.brand.theme.colors.grey3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: context.brand.theme.colors.primary,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: context.brand.theme.colors.red1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: context.brand.theme.colors.red1,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
