import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:vialer/app/resources/localizations.dart';
import 'package:vialer/app/util/conditional_capitalization.dart';
import '../../../settings/widgets/buttons/settings_button.dart';
import 'package:vialer/app/resources/theme.dart';
import '../../../../../../domain/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../resources/messages.i18n.dart';
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
    SharedContactFormCubit cubit,
    BuildContext context,
  ) {
    if (_phoneNumberFieldsCount >= _maximumPhoneNumberFields) return;

    _deletablePhoneNumberFields = List.from(_deletablePhoneNumberFields)
      ..add(
        SharedContactFieldRow(
          key: key,
          icon: null,
          hintText: context.strings.phoneNumberHintText,
          initialValue: () =>
              phoneNumbers[key].isNullOrEmpty ? null : phoneNumbers[key],
          isForPhoneNumber: true,
          validator: (value) => cubit.validatePhoneNumber(
            value,
            context,
          ),
        );
    });
  }

  void _deletePhoneNumberField(Key key) {
    phoneNumbers.remove(key);
    setState(() {
      _deletablePhoneNumberFields.removeWhere((e) => e.key == key);
    });
  }

  void _createDeletablePhoneNumberFieldsFromMap(
    SharedContactFormCubit cubit,
    BuildContext context,
  ) {
    phoneNumbers.forEach((key, value) {
      if (key != null)
        _addDeletablePhoneNumberField(
          cubit,
          context,
          key as UniqueKey,
        );
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
                context.strings.genericError,
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
              context.strings.loadingIndicator.title,
            ),
            description: Text(
              context.strings.loadingIndicator.description,
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
                  hintText: context.strings.firstNameHintText,
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
                  hintText: context.strings.lastNameHintText,
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
                  hintText: context.strings.companyHintText,
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
                  hintText: context.strings.phoneNumberHintText,
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
                          child: PlatformTextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.phonePlus,
                                  size: 16,
                                ),
                                Gap(12),
                                PlatformText(
                                  context.strings.addPhoneNumberButtonTitle,
                                ),
                              ],
                            ),
                            onPressed: () => _addDeletablePhoneNumberField(
                              cubit,
                              context,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                const SizedBox(height: 26),
                _ConclusionButton(
                  title: context.strings.saveContactButtonTitle, //wip
                  backgroundColor: context.brand.theme.colors.primary,
                  textColor: Colors.white,
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
                const Gap(6),
                if (_isEditContactForm)
                  _ConclusionButton(
                    title: context.strings.deleteContactButtonTitle,
                    backgroundColor: Colors.red.shade100,
                    textColor: context.brand.theme.colors.red1,
                    onPressed: () => _DeleteConfirmation.show(
                      context,
                      contactName: widget.sharedContact!.simpleDisplayName,
                      contactUuid: widget.sharedContact!.id,
                      sharedContactFormCubit: cubit,
                    ),
                  )
                else
                  _ConclusionButton(
                    title: context.strings.cancelButtonTitle,
                    backgroundColor: context.brand.theme.colors.primary,
                    textColor: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                const Gap(12),
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
        child: Align(
          alignment: Alignment.center,
          child: PlatformText(
            title,
            maxLines: 1,
            style: TextStyle(
              color: textColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteConfirmation extends StatelessWidget {
  const _DeleteConfirmation({
    required this.contactName,
    required this.contactUuid,
    required this.sharedContactFormCubit,
  });

  final String contactName;
  final String? contactUuid;
  final SharedContactFormCubit sharedContactFormCubit;

  static Future<void> show(
    BuildContext context, {
    required String contactName,
    required String? contactUuid,
    required SharedContactFormCubit sharedContactFormCubit,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return _DeleteConfirmation(
          contactName: contactName,
          contactUuid: contactUuid,
          sharedContactFormCubit: sharedContactFormCubit,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    Widget binIcon = FaIcon(
      FontAwesomeIcons.trashCan,
      size: 20,
      color: context.brand.theme.colors.red1,
    );
    Widget dialogTitle = Column(
      children: [
        binIcon,
        const Gap(10),
        Text(
          context.strings.confirmationDialog.deleteContactDialogTitle,
        ),
      ],
    );

    void Function() onDelete = () {
      sharedContactFormCubit.onDelete(contactUuid);
      Navigator.pop(context);
    };

    return PlatformAlertDialog(
      title: dialogTitle,
      content: Text(
        context.strings.confirmationDialog
            .deleteContactDialogContent(contactName),
      ),
      material: (_, __) => MaterialAlertDialogData(
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      ),
      actions: <Widget>[
        PlatformDialogAction(
          onPressed: () => Navigator.pop(context),
          child: PlatformText(
            context.strings.confirmationDialog.cancelButtonTitle,
          ),
        ),
        PlatformDialogAction(
          onPressed: onDelete,
          child: PlatformText(
            context.strings.confirmationDialog.deleteContactButtonTitle,
            style: TextStyle(
              color: context.brand.theme.colors.red1,
            ),
          ),
        ),
      ],
    );
  }
}

extension on Map<Key?, String> {
  List<String> toListWithoutBlankEntries() =>
      values.where((element) => element.isNotBlank).toList();
}

extension SharedContactsFormMessages on BuildContext {
  FormSharedContactsContactsMainMessages get strings =>
      msg.main.contacts.sharedContacts.form;
}
