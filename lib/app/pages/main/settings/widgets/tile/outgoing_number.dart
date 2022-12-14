import 'package:flutter/material.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'editable_value.dart';
import 'value.dart';
import 'widget.dart';

class OutgoingNumberTile extends StatelessWidget {
  final User user;

  final OutgoingNumber _value;

  OutgoingNumberTile(this.user, {super.key}) : _value = user.settings.get(_key);

  static const _key = CallSetting.outgoingNumber;

  @override
  Widget build(BuildContext context) {
    final unlockedWidget = StringSettingValue(
      user.settings,
      _key,
      value: (number) => number is UnsuppressedOutgoingNumber
          ? number.value
          : context
              .msg.main.settings.list.accountInfo.businessNumber.suppressed,
      bold: false,
    );

    return SettingTile(
      description: Text(
        context.msg.main.settings.list.accountInfo.businessNumber.description,
      ),
      childFillWidth: true,
      child: EditableSettingField(
        unlocked: Expanded(
          child: MultipleChoiceSettingValue<OutgoingNumber>(
            value: _value,
            padding: const EdgeInsets.only(
              bottom: 8,
              right: 8,
            ),
            onChanged: (number) => defaultOnChanged(context, _key, number),
            isExpanded: false,
            items: [
              DropdownMenuItem<OutgoingNumber>(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    context.msg.main.settings.list.accountInfo.businessNumber
                        .suppressed,
                  ),
                ),
                value: const OutgoingNumber.suppressed(),
              ),
              ...user.client.outgoingNumbers.map(
                (number) => DropdownMenuItem<OutgoingNumber>(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(number.toString()),
                  ),
                  value: number,
                ),
              ),
            ],
          ),
        ),
        locked: unlockedWidget,
      ),
    );
  }
}
