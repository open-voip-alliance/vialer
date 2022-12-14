import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class UseMobileNumberAsFallbackTile extends StatelessWidget {
  final User user;

  final String _mobileNumber;

  UseMobileNumberAsFallbackTile(this.user, {super.key})
      : _mobileNumber = user.settings.get(CallSetting.mobileNumber);

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.useMobileNumberAsFallback.title,
      ),
      description: Text(
        context.msg.main.settings.list.calling.useMobileNumberAsFallback
            .description(_mobileNumber),
      ),
      child: BoolSettingValue(
        user.settings,
        CallSetting.useMobileNumberAsFallback,
        onChanged: user.permissions.canChangeMobileNumberFallback
            ? defaultOnChanged
            : null,
      ),
    );
  }
}
