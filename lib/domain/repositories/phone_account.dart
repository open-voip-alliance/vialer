import 'dart:async';

import '../entities/phone_account.dart';
import 'services/voipgrid.dart';

class PhoneAccountRepository {
  final VoipgridService _service;

  PhoneAccountRepository(this._service);

  Future<PhoneAccount> getLatestAppAccountById(String id) async {
    final response = await _service.getPhoneAccount(id);

    final phoneAccount = PhoneAccount.fromJson({
      ...response.body as Map<String, dynamic>,
      // We add the id so there are no inconsistencies between a PhoneAccount
      // retrieved from this API (which does not supply the id) and from the
      // availability APIs.
      'id': id,
    });

    return phoneAccount;
  }
}
