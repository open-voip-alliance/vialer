import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/user/settings/app_setting.dart';
import '../../../../../../data/models/user/user.dart';
import 'value.dart';
import 'widget.dart';

class ShowCallsInNativeRecentsTile extends StatelessWidget {
  const ShowCallsInNativeRecentsTile(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.showCallsInNativeRecents.title,
      ),
      description: Text(
        context.msg.main.settings.list.calling.showCallsInNativeRecents
            .description(context.brand.appName),
      ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.showCallsInNativeRecents,
      ),
    );
  }
}
