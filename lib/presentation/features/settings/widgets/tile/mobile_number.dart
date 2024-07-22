import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../../data/models/user/user.dart';
import '../../../../util/phone_number.dart';
import 'category/widget.dart';
import 'dialog/base/show_setting_tile_alert_dialog.dart';
import 'dialog/edit_mobile_number_dialog.dart';
import 'widget.dart';

class MobileNumberTile extends StatelessWidget {
  const MobileNumberTile(
    this.user, {
    super.key,
  });

  final User user;

  static const _key = CallSetting.mobileNumber;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.idCard,
      titleText: context.msg.main.settings.list.accountInfo.mobileNumber.title,
      bottomBorder: false,
      children: [
        Semantics(
          explicitChildNodes: true,
          container: true,
          child: SettingTile(
            mergeSemantics: false,
            onTap: () => _launchEditMobileNumberDialog(context),
            description: Text(
              context
                  .msg.main.settings.list.accountInfo.mobileNumber.description,
            ),
            childFillWidth: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PhoneNumberText(
                  child: Text(
                    user.settings.get(_key),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const FaIcon(FontAwesomeIcons.pen, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchEditMobileNumberDialog(BuildContext context) =>
      showSettingTileAlertDialogAndSaveOnCompletion<String?>(
        context: context,
        settingKey: _key,
        builder: (context) => EditMobileNumberDialog(
          initialValue: user.settings.get(CallSetting.mobileNumber),
        ),
      );
}
