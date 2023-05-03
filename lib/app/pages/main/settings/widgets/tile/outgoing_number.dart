import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'category/widget.dart';
import 'editable_value.dart';
import 'value.dart';
import 'widget.dart';

class OutgoingNumberTile extends StatelessWidget {
  OutgoingNumberTile(
    this.user, {
    super.key,
    this.enabled = true,
  }) : _value = user.settings.get(_key);
  final User user;

  final OutgoingNumber _value;
  final bool enabled;

  static const _key = CallSetting.outgoingNumber;

  @override
  Widget build(BuildContext context) {
    final locked = StringSettingValue(
      user.settings,
      _key,
      value: (number) => number is UnsuppressedOutgoingNumber
          ? number.value
          : context
              .msg.main.settings.list.accountInfo.businessNumber.suppressed,
      bold: false,
    );

    return SettingTileCategory(
      icon: FontAwesomeIcons.phoneArrowRight,
      titleText:
          context.msg.main.settings.list.accountInfo.businessNumber.title,
      bottomBorder: false,
      children: [
        SettingTile(
          description: Text(
            context
                .msg.main.settings.list.accountInfo.businessNumber.description,
          ),
          childFillWidth: true,
          child: user.permissions.canChangeOutgoingNumber
              ? EditableSettingField(
                  unlocked: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: MultipleChoiceSettingValue<OutgoingNumber>(
                        value: _value,
                        padding: const EdgeInsets.only(
                          bottom: 8,
                          right: 8,
                        ),
                        onChanged: enabled
                            ? (number) => unawaited(
                                  defaultOnChanged(context, _key, number),
                                )
                            : null,
                        items: [
                          DropdownMenuItem<OutgoingNumber>(
                            value: const OutgoingNumber.suppressed(),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.msg.main.settings.list.accountInfo
                                    .businessNumber.suppressed,
                              ),
                            ),
                          ),
                          ...user.client.outgoingNumbers.map(
                            (number) => DropdownMenuItem<OutgoingNumber>(
                              value: number,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(number.toString()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  locked: locked,
                )
              : locked,
        ),
      ],
    );
  }
}
