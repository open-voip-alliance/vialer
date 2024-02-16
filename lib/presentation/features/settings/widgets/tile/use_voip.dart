import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../../data/models/user/user.dart';
import '../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class UseVoipTile extends StatelessWidget {
  const UseVoipTile(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(context.msg.main.settings.list.calling.useVoip.title),
      description: Text(
        context.msg.main.settings.list.calling.useVoip.description,
      ),
      child: BoolSettingValue(user.settings, CallSetting.useVoip),
    );
  }
}
