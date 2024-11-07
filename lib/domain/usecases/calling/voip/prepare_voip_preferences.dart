import 'package:dartx/dartx.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/domain/usecases/use_case.dart';

import '../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../data/models/user/settings/app_setting.dart';
import '../../../../data/models/user/settings/call_setting.dart';
import '../../../../data/models/user/user.dart';
import '../../colltacts/shared_contacts/get_shared_contacts.dart';
import '../../user/get_logged_in_user.dart';

@injectable
class PrepareVoipPreferences extends UseCase {
  final GetLoggedInUserUseCase _getUser;
  final GetSharedContactsUseCase _getSharedContactsUseCase;

  PrepareVoipPreferences(this._getUser, this._getSharedContactsUseCase);

  User get user => _getUser();

  Future<Preferences> call() async => Preferences(
        useApplicationProvidedRingtone: !user.settings.get(
          CallSetting.usePhoneRingtone,
        ),
        showCallsInNativeRecents: user.settings.get(
          AppSetting.showCallsInNativeRecents,
        ),
        supplementaryContacts: await _prepareSharedContacts(),
        enableAdvancedLogging: user.settings.get(
          AppSetting.enableAdvancedVoipLogging,
        ),
      );

  Future<Set<SupplementaryContact>> _prepareSharedContacts() async {
    final sharedContacts = await _getSharedContactsUseCase(onlyCached: true);
    return sharedContacts
        .map((contact) => contact.toSupplementaryContactsForAllNumbers())
        .flatten()
        .toSet();
  }
}

extension on SharedContact {
  Iterable<SupplementaryContact> toSupplementaryContactsForAllNumbers() =>
      phoneNumbers
          .map(
            (phoneNumber) => [
              _toSupplementaryContact(phoneNumber.phoneNumberFlat),
              _toSupplementaryContact(phoneNumber.withoutCallingCode),
            ],
          )
          .flatten();

  SupplementaryContact _toSupplementaryContact(String number) =>
      SupplementaryContact(number: number, name: displayName);
}
