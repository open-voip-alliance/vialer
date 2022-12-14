import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class ShowClientCallsTile extends StatelessWidget {
  final User user;

  const ShowClientCallsTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.showClientCalls.title,
      ),
      description: Text(
        user.permissions.canSeeClientCalls
            ? context.msg.main.settings.list.calling.showClientCalls.description
            : context
                .msg.main.settings.list.calling.showClientCalls.noPermission,
      ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.showClientCalls,
        onChanged: user.permissions.canSeeClientCalls ? defaultOnChanged : null,
      ),
    );
  }
}
