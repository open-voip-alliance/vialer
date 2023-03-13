import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../settings_error.dart';
import 'editable_value.dart';
import 'widget.dart';

class MobileNumberTile extends StatelessWidget {
  final User user;
  final bool showError;

  const MobileNumberTile(
    this.user, {
    super.key,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    const key = CallSetting.mobileNumber;

    return SettingTile(
      description: Text(
        context.msg.main.settings.list.accountInfo.mobileNumber.description,
      ),
      childFillWidth: true,
      child: Column(
        children: [
          SettingsError(
            visible: showError,
            message: context.msg.onboarding.mobileNumber.error,
          ),
          StringEditSettingValue(user.settings, key),
        ],
      ),
    );
  }
}
