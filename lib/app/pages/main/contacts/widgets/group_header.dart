import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';

class GroupHeader extends StatelessWidget {
  final String group;

  const GroupHeader({Key key, @required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 4,
        left: 16,
        right: 16,
      ),
      child: Text(
        group,
        style: TextStyle(
          color: context.isIOS
              ? context.brand.theme.grey1
              : context.brand.theme.grey5,
          fontSize: 16,
          fontWeight: context.isIOS ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }
}
