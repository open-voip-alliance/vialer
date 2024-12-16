import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/domain/usecases/phone_numbers/validate_phone_number.dart';
import 'package:vialer/presentation/features/colltacts/widgets/shared_contact_form/widget.dart';

import '../../../../../../domain/usecases/colltacts/shared_contacts/create_shared_contact.dart';
import '../../../../../../domain/usecases/colltacts/shared_contacts/delete_shared_contact.dart';
import '../../../../../../domain/usecases/colltacts/shared_contacts/update_shared_contact.dart';
import 'state.dart';

class SharedContactFormCubit extends Cubit<SharedContactFormState> {
  SharedContactFormCubit()
      : super(
          const SharedContactFormState.idle(),
        );

  final _createSharedContact = CreateSharedContactUseCase();
  final _deleteSharedContact = DeleteSharedContactUseCase();
  final _updateSharedContact = UpdateSharedContactUseCase();
  final _validatePhoneNumber = ValidatePhoneNumber();

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
      return context.strings.tooLongText;
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
      return context.strings.provideAtLeastOneField;
    }
    return null;
  }

  Future<String?> validatePhoneNumber(
    String? number,
    BuildContext context,
  ) async {
    if (number == null) return null;

    if (number.length > 128) {
      return context.strings.tooLongPhoneNumber;
    }

    if (number.length >= 10 && !number.startsWith('+')) {
      return context.strings.missingCountryCode;
    }

    return (await _validatePhoneNumber(number))
        ? null
        : context.strings.invalidPhoneNumber;
  }

  void onSave(
    bool isEditContactForm,
    String? contactUuid,
    String? firstName,
    String? lastName,
    String? company,
    List<String>? phoneNumbers,
  ) async {
    emit(SharedContactFormState.inProgress());

    try {
      if (isEditContactForm)
        await _updateSharedContact(
          uuid: contactUuid,
          firstName: firstName,
          lastName: lastName,
          company: company,
          phoneNumbers: phoneNumbers ?? const [],
        );
      else
        await _createSharedContact(
          firstName: firstName,
          lastName: lastName,
          company: company,
          phoneNumbers: phoneNumbers ?? const [],
        );

      emit(SharedContactFormState.saved());
    } catch (error) {
      emit(
        SharedContactFormState.error(
          firstName: firstName,
          lastName: lastName,
          company: company,
          phoneNumbers: phoneNumbers,
        ),
      );
    }
  }

  void onDelete(
    String? sharedContactUuid,
  ) async {
    emit(SharedContactFormState.inProgress());

    try {
      await _deleteSharedContact(
        uuid: sharedContactUuid,
      );
      emit(SharedContactFormState.deleted());
    } catch (error) {
      emit(
        SharedContactFormState.error(
          uuid: sharedContactUuid,
        ),
      );
    }
  }
}
