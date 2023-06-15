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
    this.recentOutgoingNumbers = const Iterable<OutgoingNumber>.empty(),
  }) : _outgoingNumber = user.settings.get(_key);
  final User user;

  final OutgoingNumber _outgoingNumber;
  final Iterable<OutgoingNumber> recentOutgoingNumbers;
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.msg.main.settings.list.accountInfo
                                    .businessNumber.suppressed,
                              ),
                            ),
                          ),
                          if (recentOutgoingNumbers.isNotEmpty)
                            DropdownMenuItem<OutgoingNumber>(
                              enabled: false,
                              value: const OutgoingNumber.section(),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  context.msg.main.settings.list.accountInfo
                                      .businessNumber.section.recently,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                  child: Text(number.toString()),
                                ),
                              ),
                            ),
                          if (recentOutgoingNumbers.isNotEmpty)
                            DropdownMenuItem<OutgoingNumber>(
                              enabled: false,
                              value: const OutgoingNumber.section(),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  context.msg.main.settings.list.accountInfo
                                      .businessNumber.section.other,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ...availableOutgoingNumbers.map(
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
