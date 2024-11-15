import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/data/models/user/settings/app_setting.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../../data/models/user/user.dart';
import 'value.dart';
import 'widget.dart';

class EnableAdvancedVoipLoggingTile extends StatelessWidget {
  const EnableAdvancedVoipLoggingTile(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.advancedSettings
            .enableAdvancedVoipLogging.title,
      ),
      description: Text(
        context.msg.main.settings.list.advancedSettings
            .enableAdvancedVoipLogging.description,
      ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.enableAdvancedVoipLogging,
      ),
    );
  }
}
