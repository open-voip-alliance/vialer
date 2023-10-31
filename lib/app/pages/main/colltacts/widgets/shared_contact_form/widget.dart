import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/resources/localizations.dart';
import 'package:vialer/app/util/conditional_capitalization.dart';

import '../../../settings/widgets/buttons/settings_button.dart';
import '../../../widgets/conditional_placeholder.dart';
import '../../../widgets/header.dart';
import 'cubit.dart';
import 'state.dart';
import 'util/field_row.dart';

/// This is a back-end limitation
const _maximumPhoneNumberFields = 10;

class SharedContactForm extends StatelessWidget {
  const SharedContactForm({
    required this.title,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final String title;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Header(title),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 32,
          ),
          child: _SharedContactForm(
            onSave: onSave,
          ),
        ),
      ),
    );
  }
}

class _SharedContactForm extends StatefulWidget {
  const _SharedContactForm({
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSave;

  @override
  State<_SharedContactForm> createState() => _SharedContactFormState();
}

class _SharedContactFormState extends State<_SharedContactForm> {
  String? firstName;
  String? lastName;
  String? company;

  Map<Key?, String> phoneNumbers = {};
  List<SharedContactFieldRow> _deletablePhoneNumberFields = [];

  int get _phoneNumberFieldsCount => _deletablePhoneNumberFields.length + 1;

  void _addDeletablePhoneNumberField(
      SharedContactFormCubit cubit, BuildContext context) {
    final key = UniqueKey();
    _deletablePhoneNumberFields = List.from(_deletablePhoneNumberFields)
      ..add(
        SharedContactFieldRow(
          key: key,
          icon: null,
          hintText:
              context.msg.main.contacts.sharedContacts.form.phoneNumberHintText,
          initialValue: () =>
              phoneNumbers[key].isNullOrEmpty ? null : phoneNumbers[key],
          isForPhoneNumber: true,
          validator: (value) => cubit.validatePhoneNumber(
            value,
            context,
          ),
          onValueChanged: (value) => phoneNumbers[key] = value,
          isDeletable: true,
          onDelete: (key) => _deletePhoneNumberField(key),
        ),
      );
  }

  void _deletePhoneNumberField(Key key) {
    phoneNumbers.remove(key);
    setState(() {
      _deletablePhoneNumberFields.removeWhere((e) => e.key == key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SharedContactFormCubit, SharedContactFormState>(
      listenWhen: (oldState, newState) => oldState != newState,
      listener: (context, state) {
        if (state is Success) {
          widget.onSave();
          Navigator.pop(context);
          return;
        }

        if (state is Error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(
                context.msg.main.contacts.sharedContacts.form.genericError,
              ),
            ));
        }
      },
      builder: (context, state) {
        final _formKey = GlobalKey<FormState>();
        final cubit = context.read<SharedContactFormCubit>();

        if (state is InProgress) {
          return LoadingIndicator(
            title: Text(
              context
                  .msg.main.contacts.sharedContacts.form.loadingIndicator.title,
            ),
            description: Text(
              context.msg.main.contacts.sharedContacts.form.loadingIndicator
                  .description,
            ),
          );
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SharedContactFieldRow(
                  icon: FontAwesomeIcons.user,
                  hintText: context
                      .msg.main.contacts.sharedContacts.form.firstNameHintText,
                  initialValue: () =>
                      firstName.isNullOrEmpty ? null : firstName,
                  validator: (value) => cubit.validateText(
                    value,
                    firstName,
                    lastName,
                    company,
                    context,
                  ),
                  onValueChanged: (value) => firstName = value,
                ),
                SharedContactFieldRow(
                  icon: null,
                  hintText: context
                      .msg.main.contacts.sharedContacts.form.lastNameHintText,
                  initialValue: () => lastName.isNullOrEmpty ? null : lastName,
                  validator: (value) => cubit.validateText(
                    value,
                    firstName,
                    lastName,
                    company,
                    context,
                  ),
                  onValueChanged: (value) => lastName = value,
                ),
                SharedContactFieldRow(
                  icon: FontAwesomeIcons.building,
                  hintText: context
                      .msg.main.contacts.sharedContacts.form.companyHintText,
                  initialValue: () => company.isNullOrEmpty ? null : company,
                  validator: (value) => cubit.validateText(
                    value,
                    firstName,
                    lastName,
                    company,
                    context,
                  ),
                  onValueChanged: (value) => company = value,
                ),
                SharedContactFieldRow(
                  icon: FontAwesomeIcons.phone,
                  hintText: context.msg.main.contacts.sharedContacts.form
                      .phoneNumberHintText,
                  initialValue: () => phoneNumbers[null].isNullOrEmpty
                      ? null
                      : phoneNumbers[null],
                  isForPhoneNumber: true,
                  validator: (value) => cubit.validatePhoneNumber(
                    value,
                    context,
                  ),
                  onValueChanged: (value) => phoneNumbers[null] = value,
                ),
                Column(
                  children: _deletablePhoneNumberFields,
                ),
                const SizedBox(height: 3),
                if (_phoneNumberFieldsCount < _maximumPhoneNumberFields)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 16,
                          alignment: Alignment.center,
                          child: const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: SettingsButton(
                            onPressed: () => setState(() {
                              if (_phoneNumberFieldsCount <
                                  _maximumPhoneNumberFields) {
                                _addDeletablePhoneNumberField(
                                  cubit,
                                  context,
                                );
                              }
                            }),
                            solid: false,
                            icon: FontAwesomeIcons.phonePlus,
                            text: context.msg.main.contacts.sharedContacts.form
                                .addPhoneNumberButtonTitle
                                .toUpperCaseIfAndroid(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                const SizedBox(height: 36),
                _ConclusionButton(
                  title: context
                      .msg.main.contacts.sharedContacts.form.cancelButtonTitle
                      .toUpperCaseIfAndroid(context),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 6),
                _ConclusionButton(
                  title: context.msg.main.contacts.sharedContacts.form
                      .saveContactButtonTitle
                      .toUpperCaseIfAndroid(context),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      cubit.onSubmit(
                        firstName,
                        lastName,
                        company,
                        phoneNumbers.toListWithoutBlankEntries(),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConclusionButton extends StatelessWidget {
  const _ConclusionButton({
    required this.title,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String title;
  final void Function() onPressed;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 36,
      ),
      child: SettingsButton(
        onPressed: onPressed,
        text: title,
      ),
    );
  }
}

extension on Map<Key?, String> {
  List<String> toListWithoutBlankEntries() =>
      values.where((element) => element.isNotBlank).toList();
}
