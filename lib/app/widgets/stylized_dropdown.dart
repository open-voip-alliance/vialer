import 'package:flutter/material.dart';

import '../resources/theme.dart';

class StylizedDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final bool isExpanded;
  final ValueChanged<T?> onChanged;

  const StylizedDropdown({
    super.key,
    required this.value,
    required this.items,
    this.isExpanded = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBoxDecoration = context.brand.theme.fieldBoxDecoration;

    return Container(
      decoration: BoxDecoration(
        border: context.isAndroid ? fieldBoxDecoration.border : null,
        borderRadius: fieldBoxDecoration.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          isExpanded: isExpanded,
          isDense: false,
          borderRadius: BorderRadius.circular(4),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
