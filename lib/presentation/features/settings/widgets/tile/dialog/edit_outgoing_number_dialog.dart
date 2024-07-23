import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/widgets/tile/dialog/base/setting_tile_alert_dialog.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/calling/outgoing_number/outgoing_number.dart';
import '../../../../../../data/models/user/user.dart';
import '../../../../../util/phone_number.dart';
import '../../../../call/widgets/outgoing_number_prompt/item.dart';

class EditOutgoingNumberDialog extends StatefulWidget {
  final OutgoingNumber initialValue;
  final User user;
  final Iterable<OutgoingNumber> recentOutgoingNumbers;

  const EditOutgoingNumberDialog({
    super.key,
    required this.initialValue,
    required this.user,
    this.recentOutgoingNumbers = const Iterable<OutgoingNumber>.empty(),
  });

  @override
  State<EditOutgoingNumberDialog> createState() =>
      _EditOutgoingNumberDialogState();
}

class _EditOutgoingNumberDialogState extends State<EditOutgoingNumberDialog> {
  OutgoingNumber? _currentValue;

  OutgoingNumber get _value => _currentValue ?? widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final recentOutgoingNumbers = widget.recentOutgoingNumbers;

    // No duplicates allowed in a dropdown, so remove the recent outgoing
    // numbers from the available numbers.
    final availableOutgoingNumbers = widget.user.client.outgoingNumbers
        .where((number) => !recentOutgoingNumbers.contains(number));

    final items = [
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
                context.msg.main.settings.list.accountInfo.businessNumber
                    .section.recently,
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
                context.msg.main.settings.list.accountInfo.businessNumber
                    .section.other,
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
    ];

    return SettingTileAlertDialog<OutgoingNumber>(
      currentValue: _currentValue,
      title: context.msg.main.settings.list.accountInfo.businessNumber.title,
      description:
          context.msg.main.settings.list.accountInfo.businessNumber.description,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            value: items.map((item) => item.value).contains(_value)
                ? _value
                : null,
            items: items,
            isExpanded: true,
            isDense: false,
            padding: EdgeInsets.zero,
            onChanged: (value) => setState(() => _currentValue = value),
            decoration: InputDecoration(
              icon: FaIcon(FontAwesomeIcons.phoneArrowRight),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.brand.theme.colors.grey5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.brand.theme.colors.grey4,
                ),
              ),
              errorMaxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
