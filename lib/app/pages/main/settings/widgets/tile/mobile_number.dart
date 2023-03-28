import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'category/widget.dart';
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

    return SettingTileCategory(
      icon: FontAwesomeIcons.idCard,
      titleText: context.msg.main.settings.list.accountInfo.mobileNumber.title,
      bottomBorder: false,
      children: [
        SettingTile(
          description: Text(
            context.msg.main.settings.list.accountInfo.mobileNumber.description,
          ),
          childFillWidth: true,
          child: StringEditSettingValue(user.settings, key),
        ),
      ],
    );
  }
}
