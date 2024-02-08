import 'package:flutter/material.dart';

import 'package:vialer/presentation/resources/theme.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({
    required this.group,
    this.padding = const EdgeInsets.only(
      top: 16,
      bottom: 4,
      left: 16,
      right: 16,
    ),
    super.key,
  });

  final String group;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        group,
        style: TextStyle(
          color: context.isIOS
              ? context.brand.theme.colors.grey1
              : context.brand.theme.colors.grey5,
          fontSize: 16,
          fontWeight: context.isIOS ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }
}
