import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import 'value.dart';
import 'widget.dart';

class UsePhoneRingtoneTile extends StatelessWidget {
  const UsePhoneRingtoneTile(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.audio.usePhoneRingtone.title,
      ),
      description: Text(
        context.msg.main.settings.list.audio.usePhoneRingtone.description(
          context.brand.appName,
        ),
      ),
      child: BoolSettingValue(user.settings, CallSetting.usePhoneRingtone),
    );
  }
}
