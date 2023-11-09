import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/util/phone_number.dart';
import 'package:vialer/domain/user/settings/settings_repository.dart';

import '../../../../../../domain/user/settings/settings.dart';
import '../../../../../widgets/stylized_dropdown.dart';
import '../../../../onboarding/widgets/stylized_text_field.dart';
import 'value.dart';

class EditableSettingField extends StatefulWidget {
  const EditableSettingField({
    required this.unlocked,
    required this.locked,
    super.key,
  });

  final Widget unlocked;
  final Widget locked;

  @override
  State<EditableSettingField> createState() => _EditableSettingFieldState();
}

class _EditableSettingFieldState extends State<EditableSettingField> {
  bool _editing = false;

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_editing) widget.unlocked else widget.locked,
        IconButton(
          onPressed: _toggleEditing,
          icon: const _EditIcon(),
        ),
      ],
    );
  }
}

class StringEditSettingValue extends StatefulWidget {
  StringEditSettingValue(
    this.settings,
    this.setting, {
    this.validate,
    this.help,
    this.editingFormatter,
    this.onChanged = defaultOnSettingChanged,
    this.isResettable = false,
    super.key,
  }) : value = settings.get(setting);
  final SettingsRepository settings;
  final SettingKey<String> setting;
  final ValueChangedWithContext<String> onChanged;

  /// A callback to validate the input, should return TRUE if the provided
  /// string is valid input.
  final Future<bool> Function(String)? validate;

  /// A help widget that will be displayed above the input field if [validate]
  /// fails. This will have no effect if [validate] is `null`.
  final Widget? help;

  /// Allows for formatting of the value while the user is editing, this can
  /// be used to add a prefix or suffix to make it clear what the user
  /// should be inputting.
  final String Function(String)? editingFormatter;

  /// If set to true, will show an icon on invalid input that allows resetting
  /// the field back to the original value.
  final bool isResettable;

  final String value;

  @override
  State<StringEditSettingValue> createState() => _StringEditSettingValueState();
}

class _StringEditSettingValueState extends State<StringEditSettingValue> {
  final _textEditingController = TextEditingController();
  bool _editing = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _initializeWithWidgetValue();
  }

  void _initializeWithWidgetValue() {
    _editing = false;

    _textEditingController.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );

    _validate();
  }

  void _onPressed(BuildContext context) {
    widget.onChanged(context, widget.setting, _textEditingController.text);
    unawaited(_toggleEditing());
  }

  Future<void> _toggleEditing() async {
    void toggle() => setState(() => _editing = !_editing);

    // We always cancel editing, even if we're not connected to the
    // internet.
    if (_editing) {
      toggle();
      return;
    }

    await runIfSettingCanBeChanged(context, [widget.setting], toggle);
  }

  void _applyEditingFormatter() {
    setState(() {
      final formatter = widget.editingFormatter;

      if (formatter != null) {
        final value = formatter(_textEditingController.text);

        _textEditingController.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    });
  }

  void _validate() async {
    final validate = widget.validate;

    if (validate == null) {
      setState(() => _isValid = true);
      return;
    }

    final isValid = await validate(_textEditingController.text);

    setState(() => _isValid = isValid);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Column(
        children: [
          if (!_isValid && widget.help != null) widget.help!,
          StylizedTextField(
            controller: _textEditingController,
            keyboardType: TextInputType.phone,
            autoCorrect: false,
            hasError: !_isValid,
            suffix: _isValid
                ? IconButton(
                    onPressed: () => _onPressed(context),
                    icon: const FaIcon(FontAwesomeIcons.check),
                  )
                : (widget.isResettable
                    ? IconButton(
                        onPressed: _initializeWithWidgetValue,
                        icon: const FaIcon(FontAwesomeIcons.xmark),
                      )
                    : null),
            elevation: 0,
            onChanged: (text) {
              _applyEditingFormatter();
              _validate();
            },
            semanticsLabel:
                _textEditingController.text.asSemanticsLabelIfPhoneNumber,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          PhoneNumberText(
            child: Text(
              widget.value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: _toggleEditing,
            icon: const _EditIcon(),
          ),
        ],
      );
    }
  }
}

class MultipleChoiceSettingValue<T> extends StatelessWidget {
  const MultipleChoiceSettingValue({
    required this.value,
    required this.items,
    this.isExpanded = false,
    this.onChanged,
    EdgeInsets? padding,
    super.key,
  }) : padding = padding ?? const EdgeInsets.only(right: 16);
  final T value;
  final List<DropdownMenuItem<T>> items;
  final bool isExpanded;
  final ValueChanged<T>? onChanged;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: StylizedDropdown<T>(
        value: items.map((item) => item.value).contains(value) ? value : null,
        items: items,
        isExpanded: isExpanded,
        onChanged: onChanged != null ? (value) => onChanged!(value as T) : null,
      ),
    );
  }
}

class _EditIcon extends StatelessWidget {
  const _EditIcon();

  @override
  Widget build(BuildContext context) {
    return const FaIcon(
      FontAwesomeIcons.pen,
      size: 18,
    );
  }
}
