import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'editable_value.dart';
import 'value.dart';
import 'widget.dart';

class MobileNumberTile extends StatelessWidget {
  final User user;
  final bool isVoipAllowed;

  const MobileNumberTile(
    this.user, {
    super.key,
    required this.isVoipAllowed,
  });

  @override
  Widget build(BuildContext context) {
    const key = CallSetting.mobileNumber;

    return SettingTile(
      description: isVoipAllowed
          ? Text(
              context.msg.main.settings.list.accountInfo.mobileNumber
                  .description.voip,
            )
          : Text(
              context.msg.main.settings.list.accountInfo.mobileNumber
                  .description.noVoip,
            ),
      childFillWidth: isVoipAllowed,
      child: isVoipAllowed
          ? StringEditSettingValue(user.settings, key)
          : StringSettingValue(user.settings, key),
    );
  }
}
