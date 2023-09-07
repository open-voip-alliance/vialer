import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/item.dart';
import 'package:vialer/app/pages/main/util/phone_number.dart';

import '../../../../../../domain/calling/outgoing_number/outgoing_number.dart';
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
    this.recentOutgoingNumbers = const Iterable<OutgoingNumber>.empty(),
  }) : _outgoingNumber = user.settings.get(_key);
  final User user;

  final OutgoingNumber _outgoingNumber;
  final Iterable<OutgoingNumber> recentOutgoingNumbers;
  final bool enabled;

  static const _key = CallSetting.outgoingNumber;

  @override
  Widget build(BuildContext context) {
    final locked = OutgoingNumberInfo(
      item: user.settings.get(CallSetting.outgoingNumber),
      textStyle: TextStyle(fontSize: 16),
      subtitleTextStyle: TextStyle(fontSize: 12),
    );

    // No duplicates allowed in a dropdown, so remove the recent outgoing
    // numbers from the available numbers.
    final availableOutgoingNumbers = user.client.outgoingNumbers
        .where((number) => !recentOutgoingNumbers.contains(number));

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
                    child: MultipleChoiceSettingValue<OutgoingNumber>(
                      value: _outgoingNumber,
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        right: 8,
                      ),
                      onChanged: enabled
                          ? (number) => unawaited(
                                defaultOnSettingChanged(
                                  context,
                                  _key,
                                  number,
                                ),
                              )
                          : null,
                      items: [
                        DropdownMenuItem<OutgoingNumber>(
                          value: const OutgoingNumber.suppressed(),
                          child: OutgoingNumberInfo(
                            item: OutgoingNumber.suppressed(),
                          ),
                        ),
                        if (recentOutgoingNumbers.isNotEmpty)
                          DropdownMenuItem<OutgoingNumber>(
                            enabled: false,
                            value: const OutgoingNumber.section(),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: PhoneNumberText(
                                child: Text(
                                  context.msg.main.settings.list.accountInfo
                                      .businessNumber.section.recently,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (recentOutgoingNumbers.isNotEmpty)
                          ...recentOutgoingNumbers.map(
                            (number) => DropdownMenuItem<OutgoingNumber>(
                              value: number,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: OutgoingNumberInfo(item: number),
                              ),
                            ),
                          ),
                        if (recentOutgoingNumbers.isNotEmpty)
                          DropdownMenuItem<OutgoingNumber>(
                            enabled: false,
                            value: const OutgoingNumber.section(),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: PhoneNumberText(
                                child: Text(
                                  context.msg.main.settings.list.accountInfo
                                      .businessNumber.section.other,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ...availableOutgoingNumbers.map(
                          (number) => DropdownMenuItem<OutgoingNumber>(
                            value: number,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: OutgoingNumberInfo(item: number),
                            ),
                          ),
                        ),
                      ],
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
