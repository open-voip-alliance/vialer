import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'editable_value.dart';
import 'widget.dart';

class MobileNumberTile extends StatelessWidget {
  final User user;

  const MobileNumberTile(
    this.user, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const key = CallSetting.mobileNumber;

    return SettingTile(
      description: Text(
        context.msg.main.settings.list.accountInfo.mobileNumber.description,
      ),
      childFillWidth: true,
      child: StringEditSettingValue(user.settings, key),
    );
  }
}
