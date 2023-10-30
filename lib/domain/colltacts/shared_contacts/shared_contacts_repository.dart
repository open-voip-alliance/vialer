import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:vialer/domain/colltacts/shared_contacts/shared_contacts_service.dart';

import '../../../app/util/loggable.dart';
import '../../user/user.dart';
import '../../voipgrid/voipgrid_api_resource_collector.dart';
import 'shared_contact.dart';

class SharedContactsRepository with Loggable {
  SharedContactsRepository(
    this._service,
    this._apiResourceCollector,
  );

  final SharedContactsService _service;
  final VoipgridApiResourceCollector _apiResourceCollector;

  Future<List<SharedContact>> getSharedContacts(User user) async {
    final response = await _apiResourceCollector.collect(
      requester: (page) => _service.getSharedContacts(page: page),
      deserializer: (json) => json,
    );

    return response.map(SharedContact.fromJson).withoutNonContacts().toList();
  }

  Future<void> createSharedContact(
    String? givenName,
    String? familyName,
    String? company, [
    List<String> phoneNumbers = const [],
  ]) async {
    final formattedPhoneNumbersList = phoneNumbers
        .map(
          (phoneNumber) => {'phone_number_flat': phoneNumber},
        )
        .toList();

    final response = await _service.createSharedContact({
      'given_name': givenName ?? '',
      'family_name': familyName ?? '',
      'company_name': company ?? '',
      'phone_numbers': formattedPhoneNumbersList,
      'groups': <dynamic>[],
      'voip_accounts': <dynamic>[],
    });

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Post create shared contact');
      throw Exception('Error');
    }
  }
}

extension on Iterable<SharedContact> {
  /// The webphone added in this fake contact for some work they were doing
  /// at some point. This isn't an actual contact and should therefore always
  /// be removed.
  Iterable<SharedContact> withoutNonContacts() => filterNot(
        (contact) => contact.givenName == _unlinkedVoipAccountName,
      );
}

const _unlinkedVoipAccountName = '__UNLINKED_VOIP_ACCOUNTS__';
