import 'dart:async';

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
      requester: (page) => _service.getSharedContacts(
        authorization: 'Token ${user.email}:${user.token}',
        page: page,
      ),
      deserializer: (json) => json,
    );

    return SharedContact.listFromApiResponse(response);
  }
}
