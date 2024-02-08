import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';

class SharedContactFieldRow extends StatelessWidget {
  const SharedContactFieldRow({
    this.icon,
    required this.hintText,
    required this.validator,
    required this.onValueChanged,
    this.isForPhoneNumber = false,
    this.isDeletable = false,
    this.onDelete = null,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

  final IconData? icon;
  final String hintText;
  final String? Function(String?) validator;
  final void Function(String) onValueChanged;
  final void Function(Key)? onDelete;
  final String? Function() initialValue;
  final bool isForPhoneNumber;
  final bool isDeletable;

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
              _SharedContactTextFormField(
                hintText: hintText,
                validator: validator,
                onValueChanged: onValueChanged,
                initialValue: initialValue,
                isForPhoneNumber: isForPhoneNumber,
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
                          onPressed: () => onDelete!(key!),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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

class _SharedContactTextFormField extends StatelessWidget {
  const _SharedContactTextFormField({
    required this.hintText,
    required this.validator,
    required this.onValueChanged,
    required this.initialValue,
    this.isForPhoneNumber = false,
    Key? key,
  }) : super(key: key);

  final String hintText;
  final String? Function(String?) validator;
  final void Function(String) onValueChanged;
  final String? Function() initialValue;
  final bool isForPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        validator: validator,
        initialValue: initialValue(),
        onChanged: (value) => onValueChanged(value),
        textInputAction: TextInputAction.next,
        keyboardType: isForPhoneNumber
            ? Platform.isIOS
                ? TextInputType.numberWithOptions(signed: true)
                : TextInputType.phone
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
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
    );
  }
}
