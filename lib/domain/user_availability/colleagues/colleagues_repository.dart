import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';

import '../../../app/util/loggable.dart';
import '../../user/brand.dart';
import '../../user/user.dart';
import '../../voipgrid/voipgrid_api_resource_collector.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'colleague.dart';

class ColleaguesRepository with Loggable {
  final VoipgridService _service;
  final VoipgridApiResourceCollector apiResourceCollector =
  VoipgridApiResourceCollector();
  WebSocket? _socket;

  ColleaguesRepository(this._service);

  Future<List<Colleague>> getColleagues(User user) async {
    final clientId = user.client.id.toString();

    final users = await apiResourceCollector.collect(
      requester: (page) => _service.getUsers(
        clientId,
        page: page,
      ),
      deserializer: (json) => json,
    );

    final voipAccounts = await apiResourceCollector.collect(
      requester: (page) => _service.getUnconnectedVoipAccounts(
        clientId,
        page: page,
      ),
      deserializer: (json) => json,
    );

    return [
      ...users.map(
        (e) => Colleague(
          id: e['id'] as String,
          name: e['name'] as String,
          context: [],
        ),
      ),
      ...voipAccounts.map(
        (e) => Colleague.unconnectedVoipAccount(
          id: e['id'] as String,
          name: e['description'] as String,
          number: e['internal_number'] as String,
        ),
      ),
    ];
  }

  /// Listens to a websocket for availability updates, and will then update
  /// the provided list of colleagues with the new status and broadcast it
  /// to the returned stream.
  Stream<List<Colleague>> startListeningForAvailability({
    required User user,
    required Brand brand,
    required List<Colleague> colleagues,
  }) async* {
    if (_socket != null) {
      await stopListeningForAvailability();
    }

    final socket = await WebSocket.connect(
      '${brand.userAvailabilityWsUrl}/${user.client.uuid}',
      headers: {
        'Authorization': 'Bearer ${user.token}',
      },
    );

    _socket = socket;

    await for (final eventString in socket) {
      final event = jsonDecode(eventString as String);
      if (event['name'] != 'user_availability_changed') continue;

      final payload = event['payload'];

      final colleague = colleagues
          .where((element) => element.id == payload['user_uuid'])
          .firstOrNull;

      if (colleague == null) continue;

      yield colleagues
        ..remove(colleague)
        ..add(
          colleague.map(
                (user) => user.copyWith(
              status: ColleagueAvailabilityStatus.offline,
              destination: ColleagueDestination(
                id: '',
                number: payload['internal_number'].toString(),
                type: ColleagueDestinationType.voipAccount,
              ),
              context: [],
            ),
            // We don't get availability updates for voip accounts so we will
            // just leave them as is.
            unconnectedVoipAccount: (voipAccount) => voipAccount,
          ),
        );
    }
  }

  Future<void> stopListeningForAvailability() async =>
      _socket?.close().then((value) => _socket = null);
}
