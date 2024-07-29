import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/colltacts/controllers/shared_contact_form/state.dart';
import 'package:vialer/presentation/features/colltacts/widgets/shared_contact_form/util/field_row.dart';
import 'package:vialer/presentation/features/colltacts/widgets/shared_contact_form/widget.dart';
import 'package:dartx/dartx.dart';

import '../../controllers/shared_contact_form/cubit.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.phoneNumbers,
    required this.onValueChanged,
    this.onDelete,
  });

  final Map<Key?, String> phoneNumbers;
  final void Function(String) onValueChanged;
  final void Function(Key)? onDelete;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  String? _validationError;

  Future<void> _onValueChanged(String value) async {
    final cubit = context.read<SharedContactFormCubit>();

    final validationError = await cubit.validatePhoneNumber(
      value,
      context,
    );

    setState(() {
      _validationError = validationError;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SharedContactFormCubit, SharedContactFormState>(
        builder: (context, state) {
      return SharedContactFieldRow(
        key: widget.key,
        icon: FontAwesomeIcons.phone,
        hintText: context.strings.phoneNumberHintText,
        initialValue: () => widget.phoneNumbers[null].isNullOrEmpty
            ? null
            : widget.phoneNumbers[null],
        isForPhoneNumber: true,
        validator: (_) => _validationError,
        onValueChanged: _onValueChanged,
        isDeletable: widget.onDelete != null,
        onDelete: widget.onDelete,
      );
    });
  }
}