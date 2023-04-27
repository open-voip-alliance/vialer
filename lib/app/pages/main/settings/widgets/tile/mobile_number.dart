import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import 'category/widget.dart';
import 'editable_value.dart';
import 'widget.dart';

class MobileNumberTile extends StatelessWidget {
  const MobileNumberTile(
    this.user, {
    super.key,
  });

  final User user;

  bool _validateMobileNumber(String number) =>
      number.startsWith('+') && !number.startsWith('+0') && number.length == 12;

  String _formatMobileNumberDuringEditing(String number) =>
      number.startsWith('+') ? number : '+$number';

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
          child: StringEditSettingValue(
            user.settings,
            key,
            isResettable: true,
            validate: _validateMobileNumber,
            editingFormatter: _formatMobileNumberDuringEditing,
            help: _MobileNumberTileHelp(),
          ),
        ),
      ],
    );
  }
}

class _MobileNumberTileHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final helpColor = context.brand.theme.colors.red1;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            color: helpColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.msg.main.settings.list.accountInfo.mobileNumber.help,
              style: TextStyle(color: helpColor),
            ),
          )
        ],
      ),
    );
  }
}
