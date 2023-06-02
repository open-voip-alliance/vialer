import 'package:flutter/material.dart';

import '../resources/theme.dart';

class StylizedDropdown<T> extends StatelessWidget {
  const StylizedDropdown({
    required this.value,
    required this.items,
    this.isExpanded = false,
    this.onChanged,
    this.showIcon = true,
    super.key,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final bool isExpanded;
  final ValueChanged<T?>? onChanged;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final fieldBoxDecoration = context.brand.theme.fieldBoxDecoration;

    return Container(
      decoration: BoxDecoration(
        border: fieldBoxDecoration.border,
        borderRadius: fieldBoxDecoration.borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          isExpanded: isExpanded,
          borderRadius: BorderRadius.circular(4),
          onChanged: onChanged,
          icon: Visibility(
            visible: showIcon,
            child: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }
}
