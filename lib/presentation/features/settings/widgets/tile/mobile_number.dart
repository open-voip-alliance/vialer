import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../../data/models/user/user.dart';
import '../../../../../../domain/usecases/phone_numbers/strictly_validate_mobile_phone_number.dart';
import 'category/widget.dart';
import 'editable_value.dart';
import 'widget.dart';

class MobileNumberTile extends StatelessWidget {
  const MobileNumberTile(
    this.user, {
    super.key,
  });

  final User user;

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
        Semantics(
          explicitChildNodes: true,
          container: true,
          child: SettingTile(
            mergeSemantics: false,
            description: Text(
              context
                  .msg.main.settings.list.accountInfo.mobileNumber.description,
            ),
            childFillWidth: true,
            child: StringEditSettingValue(
              user.settings,
              key,
              isResettable: true,
              validate: StrictlyValidateMobilePhoneNumber(),
              editingFormatter: _formatMobileNumberDuringEditing,
              help: _MobileNumberTileHelp(),
            ),
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
