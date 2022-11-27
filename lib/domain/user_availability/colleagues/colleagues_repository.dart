import 'dart:convert';
import 'dart:io';
import 'package:dartx/dartx.dart';

import '../../../app/util/loggable.dart';
import '../../event/event_bus.dart';
import '../../user/brand.dart';
import '../../user/events/logged_in_user_data_is_stale_event.dart';
import '../../user/user.dart';
import '../../voipgrid/voipgrid_api_resource_collector.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'colleague.dart';

class ColleaguesRepository with Loggable {
  final VoipgridService _service;
  final VoipgridApiResourceCollector _apiResourceCollector;
  final EventBus _eventBus;

  WebSocket? _socket;

  ColleaguesRepository(
    this._service,
    this._apiResourceCollector,
    this._eventBus,
  );

  /// This only provides the most basic information about colleagues,
  /// the rest needs to be queried by calling [startListeningForAvailability]
  /// and listening for updates.
  Future<List<Colleague>> getColleagues(User user) async {
    final clientId = user.client.id.toString();

    final users = await _apiResourceCollector.collect(
      requester: (page) => _service.getUsers(
        clientId,
        page: page,
      ),
      deserializer: (json) => json,
    );

    final voipAccounts = await _apiResourceCollector.collect(
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
    ].without(user: user);
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

      // We only care about this type of event for now (and that's all there is
      // currently) so if it's anything aside from this we just ignore it.
      if (event['name'] != 'user_availability_changed') continue;

      final payload = event['payload'] as Map<String, dynamic>;

      final userUuid = payload['user_uuid'] as String;

      final colleague = colleagues.findByUserUuid(userUuid);

      // We are going to hijack this WebSocket and emit an event when we know
      // our user has changed on the server.
      if (userUuid == user.uuid) {
        _eventBus.broadcast(LoggedInUserDataIsStaleEvent());
      }

      if (colleague == null) continue;

      // We don't want to display colleagues that do not have linked
      // destinations as these are essentially inactive users that do not
      // have any possible availability status.
      if (payload['has_linked_destinations'] != true) {
        colleagues.remove(colleague);
        yield colleagues;
        return;
      }

      yield colleagues
        ..remove(colleague)
        ..add(colleague.populateWithAvailability(payload));
    }
  }

  Future<void> stopListeningForAvailability() async =>
      _socket?.close().then((value) => _socket = null);
}

extension on List<Colleague> {
  /// Removes any users that match the provided user, this is used to remove
  /// the logged in user from the list of colleagues.
  List<Colleague> without({required User user}) =>
      filter((colleague) => colleague.id != user.uuid).toList();

  Colleague? findByUserUuid(String uuid) =>
      where((colleague) => colleague.id == uuid).firstOrNull;
}

extension on Colleague {
  Colleague populateWithAvailability(
    Map<String, dynamic> payload,
  ) =>
      map(
        (colleague) => colleague.copyWith(
          status: ColleagueAvailabilityStatus.fromServerValue(
            payload['availability'] as String,
          ),
          destination: ColleagueDestination(
            number: payload['internal_number'].toString(),
            type: ColleagueDestinationType.fromServerValue(
              payload['destination_type'] as String,
            ),
          ),
          // It doesn't seem like context is implemented at all currently so
          // it will just be an empty array for now.
          context: [],
        ),
        // We don't get availability updates for voip accounts so we will
        // just leave them as is.
        unconnectedVoipAccount: (voipAccount) => voipAccount,
      );
}
