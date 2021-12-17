import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class GroupHeader extends StatelessWidget {
  final String group;
  final EdgeInsets padding;

  const GroupHeader({
    Key? key,
    required this.group,
    this.padding = const EdgeInsets.only(
      top: 16,
      bottom: 4,
      left: 16,
      right: 16,
    ),
  }) : super(key: key);

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
