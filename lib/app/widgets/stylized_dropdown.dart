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
    return Container(
      decoration: BoxDecoration(
        border: context.isAndroid
            ? Border.all(color: context.brand.theme.colors.grey1)
            : null,
        borderRadius: BorderRadius.circular(8),
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
