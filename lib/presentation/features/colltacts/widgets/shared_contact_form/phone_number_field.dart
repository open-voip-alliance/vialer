import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/colltacts/widgets/shared_contact_form/util/field_row.dart';
import 'package:vialer/presentation/features/colltacts/widgets/shared_contact_form/widget.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.initialValue,
    required this.onValueChanged,
    required this.validator,
    this.onDelete,
  });

  final String? Function() initialValue;
  final void Function(String) onValueChanged;
  final String? Function(String?) validator;
  final void Function(Key)? onDelete;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SharedContactFieldRow(
      key: widget.key,
      icon: FontAwesomeIcons.phone,
      hintText: context.strings.phoneNumberHintText,
      initialValue: widget.initialValue,
      isForPhoneNumber: true,
      validator: widget.validator,
      onValueChanged: widget.onValueChanged,
      isDeletable: widget.onDelete != null,
      onDelete: widget.onDelete,
    );
  }
}
