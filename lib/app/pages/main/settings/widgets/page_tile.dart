import 'package:flutter/material.dart';

import '../../../../entities/setting_route_info.dart';
import '../../../../resources/theme.dart';

import 'tile.dart';

class SettingRouteTile extends StatelessWidget {
  final SettingRouteInfo info;
  final VoidCallback onTap;

  const SettingRouteTile(this.info, {Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SettingTile(
        label: Text(info.title),
        description: Text(info.description),
        child: Icon(
          VialerSans.caretRight,
          color: context.brandTheme.grey4,
        ),
      ),
    );
  }
}
