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

  /// This only provides the most basic information about colleagues,
  /// the rest needs to be queried by calling [startListeningForAvailability]
  /// and listening for updates.
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
      print(eventString);
      if (event['name'] != 'user_availability_changed') continue;

      final payload = event['payload'] as Map<String, dynamic>;

      final colleague = colleagues
          .where((element) => element.id == payload['user_uuid'])
          .firstOrNull;

      if (colleague == null) continue;

      // We don't want to display colleagues that do not have linked
      // destinations as these are essentially inactive users that do not
      // have any possible availability status.
      if (payload['has_linked_destinations'] != true) {
        colleagues.remove(colleague);
        yield colleagues;
        return;
      }

      final populatedColleague = _populateColleagueWithAvailability(
        colleague,
        payload,
      );

      yield colleagues
        ..remove(colleague)
        ..add(populatedColleague);
    }
  }

  Colleague _populateColleagueWithAvailability(
    Colleague colleague,
    Map<String, dynamic> payload,
  ) =>
      colleague.map(
        (colleague) => colleague.copyWith(
          status: _findAvailabilityStatus(payload),
          destination: ColleagueDestination(
            number: payload['internal_number'].toString(),
            type: _findDestinationType(payload),
          ),
          // It doesn't seem like context is implemented at all currently so
          // it will just be an empty array for now.
          context: [],
        ),
        // We don't get availability updates for voip accounts so we will
        // just leave them as is.
        unconnectedVoipAccount: (voipAccount) => voipAccount,
      );

  ColleagueAvailabilityStatus _findAvailabilityStatus(
    Map<String, dynamic> payload,
  ) {
    switch (payload['availability']) {
      case 'doNotDisturb':
        return ColleagueAvailabilityStatus.doNotDisturb;
      case 'offline':
        return ColleagueAvailabilityStatus.offline;
      case 'available':
        return ColleagueAvailabilityStatus.available;
      case 'busy':
        return ColleagueAvailabilityStatus.busy;
      default:
        return ColleagueAvailabilityStatus.unknown;
    }
  }

  ColleagueDestinationType _findDestinationType(Map<String, dynamic> payload) {
    switch (payload['destination_type']) {
      case 'app_account':
        return ColleagueDestinationType.app;
      case 'webphone_account':
        return ColleagueDestinationType.webphone;
      case 'voip_account':
        return ColleagueDestinationType.voipAccount;
      case 'fixeddestination':
        return ColleagueDestinationType.fixed;
      default:
        return ColleagueDestinationType.none;
    }
  }

  Future<void> stopListeningForAvailability() async =>
      _socket?.close().then((value) => _socket = null);
}
