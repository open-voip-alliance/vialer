import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/user/settings/settings.dart';
import '../../../../../widgets/stylized_dropdown.dart';
import '../../../../onboarding/widgets/stylized_text_field.dart';
import 'value.dart';

class EditableSettingField extends StatefulWidget {
  final Widget unlocked;
  final Widget locked;

  const EditableSettingField({
    required this.unlocked,
    required this.locked,
  }) : super();

  @override
  _EditableSettingFieldState createState() => _EditableSettingFieldState();
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
        _editing ? widget.unlocked : widget.locked,
        IconButton(
          onPressed: _toggleEditing,
          icon: const _EditIcon(),
        ),
      ],
    );
  }
}

class StringEditSettingValue extends StatefulWidget {
  final Settings settings;
  final SettingKey<String> setting;
  final ValueChangedWithContext<String> onChanged;

  final String value;

  StringEditSettingValue(
    this.settings,
    this.setting, {
    // ignore: unused_element
    this.onChanged = defaultOnChanged,
  }) : value = settings.get(setting);

  @override
  _StringEditSettingValueState createState() => _StringEditSettingValueState();
}

class _StringEditSettingValueState extends State<StringEditSettingValue> {
  final _textEditingController = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();

    _textEditingController.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  void _onPressed(BuildContext context) {
    widget.onChanged(context, widget.setting, _textEditingController.text);
    _toggleEditing();
  }

  Future<void> _toggleEditing() async {
    void toggle() => setState(() => _editing = !_editing);

    // We always cancel editing, even if we're not connected to the
    // internet.
    if (_editing) {
      toggle();
      return;
    }

    await runIfSettingCanBeChanged(context, widget.setting, toggle);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return StylizedTextField(
        controller: _textEditingController,
        keyboardType: TextInputType.phone,
        autoCorrect: false,
        suffix: IconButton(
          onPressed: () => _onPressed(context),
          icon: const FaIcon(FontAwesomeIcons.check),
        ),
        elevation: 0,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            widget.value,
            style: const TextStyle(
              fontSize: 16,
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
  final T value;
  final List<DropdownMenuItem<T>> items;
  final bool isExpanded;
  final ValueChanged<T> onChanged;
  final EdgeInsets padding;

  const MultipleChoiceSettingValue({
    super.key,
    required this.value,
    required this.items,
    this.isExpanded = false,
    required this.onChanged,
    EdgeInsets? padding,
  }) : padding = padding ?? const EdgeInsets.only(right: 16);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: StylizedDropdown<T>(
        value: items.map((item) => item.value).contains(value) ? value : null,
        items: items,
        isExpanded: isExpanded,
        onChanged: (value) => onChanged(value!),
      ),
    );
  }
}

class _EditIcon extends StatelessWidget {
  const _EditIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FaIcon(
      FontAwesomeIcons.pen,
      size: 22,
    );
  }
}
