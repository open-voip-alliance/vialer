import 'dart:async';
import 'dart:io';

import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/relations/websocket/relations_websocket_event_dispatcher.dart';
import 'package:vialer/domain/user/get_brand.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../app/util/reconnection_strategy.dart';
import '../../user/brand.dart';
import '../../user/user.dart';
import '../colleagues/colleague.dart';

class RelationsWebsocket with Loggable {
  RelationsWebsocket();

  WebSocket? _socket;

  StreamController<List<Colleague>>? _controller;

  Stream<List<Colleague>>? broadcastStream;

  bool get isWebSocketConnected => _socket != null;

  Timer? _reconnectTimer;

  final _reconnectionStrategy = ReconnectionStrategy(
    const RetryPattern(
      initialDelay: Duration(seconds: 10),
      jitter: true,
    ),
  );

  bool _doNotReconnect = false;

  /// We will store some events in a buffer
  final _buffer = <dynamic>[];

  Future<void> connect() async {
    if (_socket != null) return;

    Future<void> attemptReconnect(int? closeCode, String log) async {
      if (_doNotReconnect) {
        logger.info('Not attempting to reconnect as closed locally');
        return;
      }
      logger.warning(log);
      await disconnect(RelationsWebSocketCloseReason.remote);
      await _attemptReconnect();
    }

    try {
      await _connectToWebSocketServer(
        GetLoggedInUserUseCase()(),
        GetBrand()(),
      );
    } on Exception catch (e) {
      unawaited(
        attemptReconnect(_socket?.closeCode, 'Failed to start websocket: $e'),
      );
    }

    final eventDispatcher = RelationsWebsocketEventDispatcher();

    _socket!.listen(
      (data) {
        print("TEST123 - socket");
        // If we are receiving events, we will make sure to cancel any queued
        // reconnect timer as we are obviously connected.
        _cancelQueuedReconnect(resetAttempts: true);
        return eventDispatcher.onData(data);
      },
      onDone: () => attemptReconnect(
        _socket?.closeCode,
        'UA WS has closed',
      ),
      onError: (dynamic e) => attemptReconnect(
        _socket?.closeCode,
        'UA WS error: $e',
      ),
    );
  }

  Future<WebSocket> _connectToWebSocketServer(
    User user,
    Brand brand,
  ) async {
    _doNotReconnect = false;
    await _socket?.close();
    final url = '${brand.userAvailabilityWsUrl}/${user.client.uuid}';

    logger.info('Attempting connection to UA WebSocket at: $url');

    return _socket = await WebSocket.connect(
      url,
      headers: {
        'Authorization': 'Bearer ${user.token}',
      },
    )
      ..pingInterval = const Duration(seconds: 30);
  }

  Future<void> disconnect([
    RelationsWebSocketCloseReason reason = RelationsWebSocketCloseReason.local,
  ]) async {
    logger.info('Disconnecting from UA WebSocket');
    _doNotReconnect = true;
    await _socket?.close();
    _controller?.addError(reason);
    _socket = null;
    broadcastStream = null;
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
}

/// Indicates the reason why the `_controller` has been closed.
enum RelationsWebSocketCloseReason {
  /// We closed the socket, likely to refresh it.
  local,

  /// The remote server closed the socket, this indicates an error.
  remote,
}
