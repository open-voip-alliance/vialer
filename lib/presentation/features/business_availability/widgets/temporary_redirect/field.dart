import 'package:flutter/material.dart';

import 'package:vialer/presentation/resources/theme.dart';

class Field extends StatelessWidget {
  const Field({
    required this.icon,
    required this.text,
    required this.onTap,
    this.hasError = false,
    super.key,
  });

  final IconData icon;
  final String text;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final boxDecoration = context.brand.theme.fieldBoxDecoration;
    final borderRadius =
        context.brand.theme.fieldBorderRadius - BorderRadius.circular(1);
    return DecoratedBox(
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
  const FieldHeader(this.text, {super.key});

  final String text;

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
