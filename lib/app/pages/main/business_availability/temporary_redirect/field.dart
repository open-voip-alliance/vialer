import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class Field extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasError;
  final VoidCallback onTap;

  const Field({
    required this.icon,
    required this.text,
    this.hasError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final boxDecoration = context.brand.theme.fieldBoxDecoration;
    final borderRadius =
        context.brand.theme.fieldBorderRadius - BorderRadius.circular(1);
    return Container(
      decoration: !hasError
          ? boxDecoration
          : boxDecoration.copyWith(
              border: Border.all(color: context.brand.theme.colors.red1),
            ),
      child: Material(
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FieldHeader extends StatelessWidget {
  final String text;

  const FieldHeader(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
