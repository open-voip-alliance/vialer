import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';

import '../../../../presentation/util/loggable.dart';
import '../../../API/colltacts/shared_contacts/shared_contacts_service.dart';
import '../../../models/colltacts/shared_contacts/shared_contact.dart';
import '../../../models/user/user.dart';
import '../../../models/voipgrid/voipgrid_api_resource_collector.dart';

@singleton
class SharedContactsRepository with Loggable {
  SharedContactsRepository(
    this._service,
    this._apiResourceCollector,
  );

  final SharedContactsService _service;
  final VoipgridApiResourceCollector _apiResourceCollector;

  String get _clientId => GetLoggedInUserUseCase()().client.uuid;

  Future<List<SharedContact>> getSharedContacts(User user) async {
    final response = await _apiResourceCollector.collect(
      requester: (page) => _service.getSharedContacts(_clientId, page: page),
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

    final response = await _service.createSharedContact(_clientId, {
      'given_name': givenName ?? '',
      'family_name': familyName ?? '',
      'company_name': company ?? '',
      'phone_numbers': formattedPhoneNumbersList,
    });

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Post create shared contact');
      throw Exception('Error');
    }
  }

  Future<void> deleteSharedContact(String? sharedContactUuid) async {
    final response = await _service.deleteSharedContact(
      _clientId,
      sharedContactUuid ?? '',
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Delete shared contact');
      throw Exception('Error');
    }
  }

  Future<void> updateSharedContact(
    String? sharedContactUuid,
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

    final response = await _service.updateSharedContact(
      _clientId,
      sharedContactUuid ?? '',
      {
        'given_name': givenName ?? '',
        'family_name': familyName ?? '',
        'company_name': company ?? '',
        'phone_numbers': formattedPhoneNumbersList,
      },
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Put update shared contact');
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
