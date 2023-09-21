import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../../domain/voipgrid/user_permissions.dart';
import '../../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class ShowClientCallsTile extends StatelessWidget {
  const ShowClientCallsTile(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.showClientCalls.title,
      ),
      description: Text(
        user.hasPermission(Permission.canSeeClientCalls)
            ? context.msg.main.settings.list.calling.showClientCalls.description
            : context
                .msg.main.settings.list.calling.showClientCalls.noPermission,
      ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.showClientCalls,
        onChanged: user.hasPermission(Permission.canSeeClientCalls)
            ? defaultOnSettingChanged
            : null,
      ),
    );
  }
}
