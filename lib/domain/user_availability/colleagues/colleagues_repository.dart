import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';

import '../../../app/util/loggable.dart';
import '../../../app/util/reconnection_strategy.dart';
import '../../event/event_bus.dart';
import '../../user/brand.dart';
import '../../user/events/logged_in_user_availability_changed.dart';
import '../../user/user.dart';
import '../../voipgrid/voipgrid_api_resource_collector.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'availbility_update.dart';
import 'colleague.dart';

class ColleaguesRepository with Loggable {
  final VoipgridService _service;
  final VoipgridApiResourceCollector _apiResourceCollector;
  final EventBus _eventBus;

  WebSocket? _socket;

  StreamController<List<Colleague>>? _controller;

  Stream<List<Colleague>>? broadcastStream;

  bool get isWebSocketConnected => _socket != null;

  Timer? _reconnectTimer;

  final _reconnectionStrategy = ReconnectionStrategy(
    const RetryPattern(
      initialDelay: Duration(seconds: 10),
      maxBackOff: 10,
      jitter: true,
    ),
  );

  /// This is the base list of colleagues that we use to update with changes
  /// from the WebSocket. The WebSocket does *not* provide enough data by
  /// itself, we need the data from the API and that is the data that is
  /// stored here.
  ///
  /// When there is new API data, this should be updated.
  List<Colleague> colleagues = [];

  ColleaguesRepository(
    this._service,
    this._apiResourceCollector,
    this._eventBus,
  );

  /// Listens to a WebSocket for availability updates, and will then update
  /// the provided list of colleagues with the new status and broadcast it
  /// to the returned stream.
  ///
  /// The availability of all users is only delivered when first opening
  /// a socket, so if you want to force a refresh you must first call
  /// [stopListeningForAvailability] and then call this method again.
  Future<Stream<List<Colleague>>> startListeningForAvailability({
    required User user,
    required Brand brand,
    required List<Colleague> initialColleagues,
  }) async {
    colleagues = initialColleagues;

    if (_socket != null) return broadcastStream!;

    Future<void> attemptReconnect(String log) async {
      logger.warning(log);
      await stopListeningForAvailability(
        reason: AvailabilityCloseReason.remote,
      );
      await _attemptReconnect(
        user: user,
        brand: brand,
        initialColleagues: initialColleagues,
      );
    }

    if (_controller == null || _controller?.isClosed == true) {
      _controller = StreamController<List<Colleague>>();
    }

    final controller = _controller!;

    late WebSocket socket;

    try {
      socket = await _connectToWebSocketServer(user, brand);
    } on Exception catch (e) {
      attemptReconnect('Failed to start websocket: $e');
      return broadcastStream = controller.stream.asBroadcastStream();
    }

    socket.listen(
      (eventString) {
        // If we are receiving events, we will make sure to cancel any queued
        // reconnect timer as we are obviously connected.
        _cancelQueuedReconnect(resetAttempts: true);

        final event = jsonDecode(eventString as String);

        // We only care about this type of event for now (and that's all there
        // is currently) so if it's anything aside from this we just ignore
        // it.
        if (event['name'] != 'user_availability_changed') return;

        final payload = event['payload'] as Map<String, dynamic>;

        final userUuid = payload['user_uuid'] as String;

        final colleague = colleagues.findByUserUuid(userUuid);

        final availability = payload.toAvailabilityUpdate();

        // We are going to hijack this WebSocket and emit an event when we
        // know our user has changed on the server.
        if (userUuid == user.uuid) {
          _eventBus.broadcast(
            LoggedInUserAvailabilityChanged(availability: availability),
          );
        }

        // If no colleague is found, we can't update the availability of it.
        if (colleague == null) return;

        // We don't want to display colleagues that do not have linked
        // destinations as these are essentially inactive users that do not
        // have any possible availability status.
        if (payload['has_linked_destinations'] != true) {
          controller.add(colleagues..remove(colleague));
          return;
        }

        colleagues.replace(
          original: colleague,
          replacement: colleague.populateWithAvailability(availability),
        );

        controller.add(colleagues);
      },
      onDone: () => attemptReconnect('UA WS has closed'),
      onError: (e) => attemptReconnect('UA WS error: $e'),
    );

    return broadcastStream = controller.stream.asBroadcastStream();
  }

  Future<WebSocket> _connectToWebSocketServer(
    User user,
    Brand brand,
  ) async {
    _socket?.close();
    final url = '${brand.userAvailabilityWsUrl}/${user.client.uuid}';

    logger.info('Attempting connection to UA WebSocket at: $url');

    return _socket = await WebSocket.connect(
      url,
      headers: {
        'Authorization': 'Bearer ${user.token}',
      },
    );
  }

  Future<void> stopListeningForAvailability({
    AvailabilityCloseReason reason = AvailabilityCloseReason.local,
  }) async {
    logger.info('Disconnecting from UA WebSocket');
    await _socket?.close;
    _controller?.addError(reason);
    _socket = null;
    broadcastStream = null;
  }

  Future<void> _attemptReconnect({
    required User user,
    required Brand brand,
    required List<Colleague> initialColleagues,
  }) async {
    if (_reconnectTimer != null) return;

    final reconnectWaitTime = _reconnectionStrategy.delayFor();

    _reconnectionStrategy.increment();

    logger.info(
      'Attempting reconnect in ${reconnectWaitTime.inMilliseconds} ms',
    );

    _reconnectTimer = Timer(reconnectWaitTime, () async {
      logger.info('Attempting websocket reconnect');
      _cancelQueuedReconnect();
      await startListeningForAvailability(
        user: user,
        brand: brand,
        initialColleagues: initialColleagues,
      );
    });
  }

  void _cancelQueuedReconnect({bool resetAttempts = false}) {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (resetAttempts) {
      _reconnectionStrategy.reset();
    }
  }

  /// This only provides the most basic information about colleagues,
  /// the rest needs to be queried by calling [startListeningForAvailability]
  /// and listening for updates.
  Future<List<Colleague>> getColleagues(User user) async {
    final clientId = user.client.id.toString();

    final users = user.permissions.canViewColleagues
        ? await _apiResourceCollector.collect(
            requester: (page) => _service.getUsers(
              clientId,
              page: page,
            ),
            deserializer: (json) => json,
          )
        : [];

    final voipAccounts = user.permissions.canViewVoipAccounts
        ? await _apiResourceCollector.collect(
            requester: (page) => _service.getUnconnectedVoipAccounts(
              clientId,
              page: page,
            ),
            deserializer: (json) => json,
          )
        : [];

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
}

extension on List<Colleague> {
  /// Removes any users that match the provided user, this is used to remove
  /// the logged in user from the list of colleagues.
  List<Colleague> without({required User user}) =>
      filter((colleague) => colleague.id != user.uuid).toList();

  Colleague? findByUserUuid(String uuid) =>
      where((colleague) => colleague.id == uuid).firstOrNull;

  void replace({required Colleague original, required Colleague replacement}) {
    final index = indexOf(original);

    replaceRange(
      index,
      index + 1,
      [replacement],
    );
  }
}

extension on Colleague {
  Colleague populateWithAvailability(
    AvailabilityUpdate availability,
  ) =>
      map(
        (colleague) => colleague.copyWith(
          status: availability.availabilityStatus,
          destination: availability.destination,
          context: availability.context,
        ),
        // We don't get availability updates for voip accounts so we will
        // just leave them as is.
        unconnectedVoipAccount: (voipAccount) => voipAccount,
      );
}

extension on List<dynamic> {
  List<ColleagueContext> buildUserAvailabilityContext() => map(
        (e) => ColleagueContext.fromServerValue(
          (e as Map<String, dynamic>)['type'] as String,
        ),
      ).filterNotNull().toList();
}

extension on Map<String, dynamic> {
  AvailabilityUpdate toAvailabilityUpdate() => AvailabilityUpdate(
        availabilityStatus: ColleagueAvailabilityStatus.fromServerValue(
          this['availability'] as String?,
        ),
        context:
            (this['context'] as List<dynamic>).buildUserAvailabilityContext(),
        internalNumber: this['internal_number'].toString(),
        destination: ColleagueDestination(
          number: this['internal_number'].toString(),
          type: ColleagueDestinationType.fromServerValue(
            this['destination_type'] as String?,
          ),
        ),
      );
}

/// Indicates the reason why the [_controller] has been closed.
enum AvailabilityCloseReason {
  /// We closed the socket, likely to refresh it.
  local,

  /// The remote server closed the socket, this indicates an error.
  remote,
}
