import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import 'value.dart';
import 'widget.dart';

class ShowCallsInNativeRecentsTile extends StatelessWidget {
  final User user;

  const ShowCallsInNativeRecentsTile(this.user, {super.key});

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
