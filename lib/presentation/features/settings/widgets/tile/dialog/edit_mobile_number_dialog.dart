import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/domain/usecases/phone_numbers/strictly_validate_mobile_phone_number.dart';
import 'package:vialer/presentation/features/settings/widgets/tile/dialog/base/setting_tile_alert_dialog.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

class EditMobileNumberDialog extends StatefulWidget {
  const EditMobileNumberDialog({
    super.key,
    this.initialValue = "",
  });

  final String initialValue;

  @override
  State<EditMobileNumberDialog> createState() => _EditMobileNumberDialogState();
}

class _EditMobileNumberDialogState extends State<EditMobileNumberDialog> {
  final _textEditingController = TextEditingController();
  bool _isValid = true;

  String get _currentValue => _textEditingController.text;

  String _formatMobileNumberDuringEditing(String number) =>
      number.startsWith('+') ? number : '+$number';

  @override
  void initState() {
    _initializeWithWidgetValue();
    super.initState();
  }

  void _applyEditingFormatter() {
    setState(() {
      final formatter = _formatMobileNumberDuringEditing;

      final value = formatter(_textEditingController.text);

      _textEditingController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    });
  }

  void _initializeWithWidgetValue() {
    _textEditingController.value = TextEditingValue(
      text: widget.initialValue,
      selection: TextSelection.collapsed(offset: widget.initialValue.length),
    );

    _validate();
  }

  Future<void> _validate() async {
    final isValid = await StrictlyValidateMobilePhoneNumber()(
      _textEditingController.text,
    );

    setState(() => _isValid = isValid);
  }

  @override
  Widget build(BuildContext context) {
    return SettingTileAlertDialog<String>(
      title: context.msg.main.settings.list.accountInfo.mobileNumber.title,
      description:
          context.msg.main.settings.list.accountInfo.mobileNumber.description,
      currentValue: _currentValue,
      canSave: _isValid,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _textEditingController,
            keyboardType: TextInputType.phone,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              icon: FaIcon(FontAwesomeIcons.simCard),
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
              error: _isValid ? null : _EditMobileNumberDialogHelp(),
              errorMaxLines: 3,
            ),
            onChanged: (_) async {
              _applyEditingFormatter();
              await _validate();
            },
          ),
        ],
      ),
    );
  }
}

class _EditMobileNumberDialogHelp extends StatelessWidget {
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
          ),
        ],
      ),
    );
  }
}
