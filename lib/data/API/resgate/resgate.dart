import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:res_client/cache/cache_item.dart';
import 'package:res_client/client.dart';
import 'package:res_client/error.dart';
import 'package:res_client/event.dart';
import 'package:res_client/model.dart' hide logger;
import 'package:vialer/data/API/resgate/payloads/device.dart';
import 'package:vialer/data/API/resgate/payloads/payload.dart';
import 'package:vialer/data/API/resgate/payloads/user_availability_changed.dart';

import '../../../../domain/usecases/onboarding/is_onboarded.dart';
import '../../../presentation/util/loggable.dart';
import '../../../presentation/util/reconnection_strategy.dart';
import 'get_resgate_authentication.dart';
import 'listeners/colleague_update_handler.dart';
import 'listeners/listener.dart';
import 'listeners/logged_in_user_availability_changed_handler.dart';
import 'listeners/update_destinations_with_is_online.dart';

typedef Deserializer = ResgatePayload Function(Map<String, dynamic>);

@singleton
class Resgate with Loggable {
  final _reconnectionStrategy = ReconnectionStrategy.defaultStrategy;

  ResClient? _resgate;

  Timer? _reconnectTimer;

  bool _doNotReconnect = false;

  ResgateAuthentication? get _auth => GetResgateAuthentication()();

  bool get isConnected => _resgate != null;

  /// Connect to the Relations WebSocket, if already connected or authentication
  /// details aren't available, nothing will happen.
  Future<void> connect() async => _connect();

  /// Disconnect from the Relations WebSocket, no retries will be queued as it
  /// is assumed this is an intentional disconnect.
  Future<void> disconnect() async => _disconnect();

  final _listenersAndDeserializers = <ResgateListener, Deserializer>{
    LoggedInUserAvailabilityChangedHandler():
        UserAvailabilityChangedPayload.fromJson,
    ColleagueUpdateHandler(): UserAvailabilityChangedPayload.fromJson,
    UpdateDestinationWithIsOnline(): DevicePayload.fromJson,
  };

  Iterable<ResgateListener> get _listeners => _listenersAndDeserializers.keys;

  Future<void> _connect({
    bool shouldUpdateListeners = true,
  }) async {
    if (_auth == null || _resgate != null) return;

    Future<void> attemptReconnect(String log) async {
      if (_doNotReconnect) {
        logger.info('Not attempting to reconnect as closed locally');
        _resgate = null;
        return;
      }
      logger.warning(log);
      await _disconnect(reason: ResgateCloseReason.remote);
      await _attemptReconnect();
    }

    try {
      await _connectToResgate(
        shouldUpdateListeners: shouldUpdateListeners,
      );
    } on Exception catch (e) {
      unawaited(
        attemptReconnect('Failed to start Resgate: $e'),
      );
      return;
    }

    final resgate = this._resgate!;

    resgate.events.listen(
      (data) async {
        if (data.isHealthyEvent) {
          // If we are receiving events, we will make sure to cancel any queued
          // reconnect timer as we are obviously connected.
          _cancelQueuedReconnect(resetAttempts: true);
        }

        if (data is DisconnectedEvent) {
          attemptReconnect('Resgate has closed');
          return;
        }
      },
      onDone: () => attemptReconnect('Resgate has closed'),
      onError: (dynamic e) => attemptReconnect(
        'Resgate error: $e',
      ),
    );
  }

  Future<void> _onConnect() async {
    await _subscribeAllListeners();
    await _callAllListenersWithCurrentData();
  }

  Future<void> _callAllListenersWithCurrentData() async {
    final resgate = _resgate!;

    for (final entry in _listenersAndDeserializers.entries) {
      final items = await resgate.getItems(
        entry.listener.resourceToSubscribeTo,
      );

      for (final item in items) {
        await _callListenerForItem(entry, item);
      }
    }
  }

  Future<void> _callListenerForItem(
    MapEntry<ResgateListener<ResgatePayload>, Deserializer> entry,
    ResModel item,
  ) async {
    try {
      final payload = entry.deserializer(item.toJson());

      if (!entry.listener.shouldHandle(payload)) return;

      return entry.listener.handle(payload);
    } catch (e) {
      logger.warning(
        'Unable to handle rid [${item.rid}] for ${entry.listener.runtimeType}',
      );
      return;
    }
  }

  Future<void> _subscribeAllListeners() async {
    final resgate = _resgate!;
    for (final entry in _listenersAndDeserializers.entries) {
      await resgate.subscribe(entry.listener.resourceToSubscribeTo, null);

      resgate.events.forListener(entry.listener).listen(
        (event) async {
          if (event is ModelChangedEvent) {
            final item = (await resgate.get(event.rid))?.item;

            if (item is ResModel) {
              _callListenerForItem(entry, item);
            }
          }
        },
      );
    }
  }

  Future<ResClient> _connectToResgate({
    bool shouldUpdateListeners = true,
  }) async {
    final auth = _auth;
    final completer = Completer<ResClient>();

    if (auth == null) {
      throw Exception('Unable to connect to WS as we have no authentication');
    }

    _doNotReconnect = false;
    _resgate?.dispose();

    logger.info('Attempting connection to WS at: ${auth.url}');

    final resgate = ResClient()
      ..reconnect(auth.url)
      ..events.handleError(_handleResgateError);

    _resgate = resgate;

    resgate.onConnected(() async {
      await resgate.authenticate(auth);

      await _onConnect();

      if (shouldUpdateListeners) {
        await performOnEachListener((l) => l.onConnect());
      }

      completer.complete(resgate);
    });

    return completer.future;
  }

  Future<void> _disconnect({
    ResgateCloseReason reason = ResgateCloseReason.local,
    bool shouldUpdateListeners = true,
  }) async {
    logger.info('Disconnecting from Resgate');
    _doNotReconnect = true;
    final resgate = _resgate;
    if (resgate == null) return;
    final completer = Completer<void>();
    resgate.onDisconnected(() => completer.complete());
    resgate.forceClose();
    _resgate = null;
    if (shouldUpdateListeners) {
      await performOnEachListener((l) => l.onDisconnect());
    }
    if (completer.isCompleted) return;
    return completer.future;
  }

  Future<void> _attemptReconnect() async {
    if (_reconnectTimer != null) return;

    final reconnectWaitTime = _reconnectionStrategy.delayFor();

    _reconnectionStrategy.increment();

    logger.info(
      'Attempting Resgate reconnect in ${reconnectWaitTime.inMilliseconds} ms',
    );

    _reconnectTimer = Timer(reconnectWaitTime, () async {
      logger.info('Attempting Resgate reconnect');
      _cancelQueuedReconnect();
      await connect();
    });
  }

  void _handleResgateError(Object e) => logger.error('Resgate error: $e');

  void _cancelQueuedReconnect({bool resetAttempts = false}) {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (resetAttempts) {
      _reconnectionStrategy.reset();
    }
  }

  Future<void> refresh() async {
    await performOnEachListener((l) => l.onRefreshRequested());
    await _disconnect(shouldUpdateListeners: false);
    await _connect(shouldUpdateListeners: false);
  }

  Future<void> performOnEachListener(ListenerCallback callback) =>
      Future.forEach(
        _listeners,
        (listener) => callback(listener),
      );
}

typedef ListenerCallback = Future<void> Function(ResgateListener);

/// Indicates the reason why the `_controller` has been closed.
enum ResgateCloseReason {
  /// We closed the socket, likely to refresh it.
  local,

  /// The remote server closed the socket, this indicates an error.
  remote,
}

extension on ResClient {
  Future<void> authenticate(ResgateAuthentication credentials) async =>
      await auth(
        'usertoken',
        'login',
        params: {'token': credentials.token},
      );

  // Normalizes a model or collection into a collection so we can handle both
  // of these in a similar way.
  Future<List<ResModel>> getItems(String rid) async {
    final data = (await get(rid) as CacheItem).item;

    if (data is ResModel) {
      return [data];
    } else if (data is ResCollection) {
      return data.items.whereType<ResModel>().toList();
    }

    return [];
  }

  void onDisconnected(void Function() callback) => events
      .where((event) => event is DisconnectedEvent)
      .listen((event) => callback());

  void onConnected(void Function() callback) => events
      .where((event) => event is ConnectedEvent)
      .listen((event) => callback());
}

extension on MapEntry<ResgateListener, Deserializer> {
  ResgateListener get listener => key;
  Deserializer get deserializer => value;
}

extension on Stream<ResEvent> {
  Stream<ResEvent> forListener(ResgateListener listener) =>
      where((event) => event.matchesRid(listener));
}

extension on ResEvent {
  bool matchesRid(ResgateListener listener) {
    if (!IsOnboarded()()) return false;

    final self = this;

    if (self is! ResourceEvent) return false;

    return self.rid.matches(listener.resourceToHandle);
  }

  /// An event that indicates that the state of Resgate is healthy, i.e. not
  /// disconnected or other errors.
  bool get isHealthyEvent => ![
        DisconnectedEvent,
        ClientForcedDisconnectedEvent,
        ClientDisconnectedException,
        InvalidMessageException,
      ].contains(runtimeType);
}
