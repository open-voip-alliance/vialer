import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/resources/localizations.dart';

import '../../../../../../domain/colltacts/shared_contacts/create_shared_contact.dart';
import 'state.dart';

class SharedContactFormCubit extends Cubit<SharedContactFormState> {
  SharedContactFormCubit()
      : super(
          const SharedContactFormState.idle(),
        );

  final _createSharedContact = CreateSharedContactUseCase();

  String? validateText(
    String? text,
    String? firstName,
    String? lastName,
    String? company,
    BuildContext context,
  ) {
    final textLengthValidation = _validateTextLength(text, context);
    if (textLengthValidation != null) {
      return textLengthValidation;
    }
    return _validateTextFields(firstName, lastName, company, context);
  }

  String? _validateTextLength(String? text, BuildContext context) {
    if (text != null && text.length > 255) {
      return context.msg.main.contacts.sharedContacts.form.tooLongText;
    }
    return null;
  }

  String? _validateTextFields(
    String? firstName,
    String? lastName,
    String? company,
    BuildContext context,
  ) {
    if (firstName.isNullOrEmpty &&
        lastName.isNullOrEmpty &&
        company.isNullOrEmpty) {
      return context
          .msg.main.contacts.sharedContacts.form.provideAtleastOneField;
    }
    return null;
  }

  String? validatePhoneNumber(String? text, BuildContext context) {
    ///TODO: validate with api call for phone number on a following ticket
    if (text != null && text.length > 128) {
      return context.msg.main.contacts.sharedContacts.form.tooLongPhoneNumber;
    }
    return null;
  }

  void onSubmit(
    String? firstName,
    String? lastName,
    String? company,
    List<String>? phoneNumbers,
  ) async {
    emit(SharedContactFormState.inProgress());

    try {
      await _createSharedContact(
        firstName: firstName,
        lastName: lastName,
        company: company,
        phoneNumbers: phoneNumbers ?? const [],
      );
      emit(SharedContactFormState.success());
    } catch (error) {
      emit(SharedContactFormState.error(
        firstName: firstName,
        lastName: lastName,
        company: company,
        phoneNumbers: phoneNumbers,
      ));
    }
  }
}
