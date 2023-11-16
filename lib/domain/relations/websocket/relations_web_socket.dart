import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/relations/websocket/relations_websocket_event_dispatcher.dart';
import '../../../app/util/reconnection_strategy.dart';
import 'get_web_socket_url.dart';

@singleton
class RelationsWebSocket with Loggable {
  late final _eventDispatcher = RelationsWebSocketEventDispatcher();

  final _reconnectionStrategy = ReconnectionStrategy.defaultStrategy;

  WebSocket? _socket;

  Timer? _reconnectTimer;

  bool _doNotReconnect = false;

  RelationsWebSocketAuthentication? get _auth => GetWebSocketAuthentication()();

  bool get isWebSocketConnected => _socket != null;

  /// Connect to the Relations WebSocket, if already connected or authentication
  /// details aren't available, nothing will happen.
  Future<void> connect() async => _connect();

  /// Disconnect from the Relations WebSocket, no retries will be queued as it
  /// is assumed this is an intentional disconnect.
  Future<void> disconnect() async => _disconnect();

  Future<void> _connect({
    bool shouldUpdateListeners = true,
  }) async {
    if (_auth == null || _socket != null) return;

    Future<void> attemptReconnect(int? _, String log) async {
      if (_doNotReconnect) {
        logger.info('Not attempting to reconnect as closed locally');
        _socket = null;
        return;
      }
      logger.warning(log);
      await _disconnect(reason: RelationsWebSocketCloseReason.remote);
      await _attemptReconnect();
    }

    try {
      await _createWebSocketConnection(
        shouldUpdateListeners: shouldUpdateListeners,
      );
    } on Exception catch (e) {
      unawaited(
        attemptReconnect(_socket?.closeCode, 'Failed to start WS: $e'),
      );
    }

    _socket!.listen(
      (data) {
        // If we are receiving events, we will make sure to cancel any queued
        // reconnect timer as we are obviously connected.
        _cancelQueuedReconnect(resetAttempts: true);
        return _eventDispatcher.onData(data);
      },
      onDone: () => attemptReconnect(_socket?.closeCode, 'WS has closed'),
      onError: (dynamic e) => attemptReconnect(
        _socket?.closeCode,
        'WS error: $e',
      ),
    );
  }

  Future<WebSocket> _createWebSocketConnection({
    bool shouldUpdateListeners = true,
  }) async {
    final auth = _auth;

    if (auth == null) {
      throw Exception('Unable to connect to WS as we have no authentication');
    }

    _doNotReconnect = false;
    await _socket?.close();

    logger.info('Attempting connection to WS at: ${auth.url}');

    _socket = await WebSocket.connect(auth.url, headers: auth.headers)
      ..pingInterval = const Duration(seconds: 30);

    if (shouldUpdateListeners) {
      await _eventDispatcher.performOnEachListener((l) => l.onConnect());
    }

    return _socket!;
  }

  Future<void> _disconnect({
    RelationsWebSocketCloseReason reason = RelationsWebSocketCloseReason.local,
    bool shouldUpdateListeners = true,
  }) async {
    logger.info('Disconnecting from WS');
    _doNotReconnect = true;
    await _socket?.close();
    _socket = null;
    if (shouldUpdateListeners) {
      await _eventDispatcher.performOnEachListener((l) => l.onDisconnect());
    }
  }

  Future<void> _attemptReconnect() async {
    if (_reconnectTimer != null) return;

    final reconnectWaitTime = _reconnectionStrategy.delayFor();

    _reconnectionStrategy.increment();

    logger.info(
      'Attempting reconnect in ${reconnectWaitTime.inMilliseconds} ms',
    );

    _reconnectTimer = Timer(reconnectWaitTime, () async {
      logger.info('Attempting websocket reconnect');
      _cancelQueuedReconnect();
      await connect();
    });
  }

  void _cancelQueuedReconnect({bool resetAttempts = false}) {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (resetAttempts) {
      _reconnectionStrategy.reset();
    }
  }

  Future<void> refresh() async {
    await _eventDispatcher.performOnEachListener((l) => l.onRefreshRequested());
    await _disconnect(shouldUpdateListeners: false);
    await _connect(shouldUpdateListeners: false);
  }
}

/// Indicates the reason why the `_controller` has been closed.
enum RelationsWebSocketCloseReason {
  /// We closed the socket, likely to refresh it.
  local,

  /// The remote server closed the socket, this indicates an error.
  remote,
}
