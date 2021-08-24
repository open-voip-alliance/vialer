import 'dart:async';
import 'dart:io';

import 'package:flutter_phone_lib/audio/audio_route.dart';
import 'package:flutter_phone_lib/audio/audio_state.dart';
import 'package:flutter_phone_lib/audio/bluetooth_audio_route.dart';
import 'package:flutter_phone_lib/call_session_state.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart' hide Logger;
import 'package:logging/logging.dart';

import '../../app/util/debug.dart';
import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/brand.dart';
import '../entities/build_info.dart';
import '../entities/setting.dart';
import '../entities/voip_config.dart';
import '../usecases/enable_console_logging.dart';
import '../usecases/enable_remote_logging_if_needed.dart';
import '../usecases/get_build_info.dart';
import '../usecases/get_setting.dart';
import '../usecases/get_user.dart';
import 'logging.dart';
import 'operating_system_info.dart';
import 'services/middleware.dart';
import 'storage.dart';

class VoipRepository with Loggable {
  late PhoneLib _phoneLib;

  final _hasStartedCompleter = Completer<bool>();

  Future<bool> get hasStarted => _hasStartedCompleter.future;

  Future<void> initializeAndStart({
    required VoipConfig config,
    required Brand brand,
    required BuildInfo buildInfo,
  }) async {
    if (_hasStartedCompleter.isCompleted) {
      start(config);
      return;
    }

    hasStarted.whenComplete(() => start(config));

    final preferences = await _createPreferences(config);

    _phoneLib = await initializePhoneLib((builder) {
      builder
        ..auth = _createAuth(config)
        ..preferences = preferences;

      return ApplicationSetup(
        initialize: _initialize,
        logger: _onLogReceived,
        middleware: const Middleware(
          respond: _middlewareRespond,
          tokenReceived: _middlewareTokenReceived,
          inspect: _middlewareInspect,
        ),
        userAgent: '${brand.appName} '
            '${Platform.isAndroid ? 'Android' : 'iOS'} '
            'v${buildInfo.version}',
      );
    });

    logger.info('PhoneLib started');

    _hasStartedCompleter.complete(true);
  }

  Auth _createAuth(VoipConfig config) => Auth(
        username: config.sipUserId.toString(),
        password: config.password,
        domain: config.useEncryption
            ? 'sip.encryptedsip.com'
            : 'sipproxy.voipgrid.nl',
        port: config.useEncryption ? 5061 : 5060,
        secure: config.useEncryption,
      );

  Future<Preferences> _createPreferences(VoipConfig config) async {
    final getPhoneRingtone = GetSettingUseCase<UsePhoneRingtoneSetting>();

    return Preferences(
      codecs: [Codec.opus],
      useApplicationProvidedRingtone: !(await getPhoneRingtone()).value,
    );
  }

  Future<void> start(VoipConfig config) async => _phoneLib.start(
        await _createPreferences(config),
        _createAuth(config),
      );

  Future<void> stop() => _phoneLib.stop();

  Future<void> call(String number) => _phoneLib.call(number.normalize());

  Future<void> answerCall() => _phoneLib.actions.answer();

  Future<void> refreshPreferences(VoipConfig config) async =>
      _phoneLib.updatePreferences(await _createPreferences(config));

  Future<Call?> get activeCall => _phoneLib.calls.active;

  Future<CallSessionState> get sessionState => _phoneLib.sessionState;

  Future<void> endCall() => _phoneLib.actions.end();

  Future<void> sendDtmf(String dtmf) => _phoneLib.actions.sendDtmf(dtmf);

  Stream<Event> get events => _phoneLib.events;

  Future<void> register(VoipConfig voipConfig) =>
      _Middleware().register(voipConfig);

  Future<void> unregister(VoipConfig voipConfig) =>
      _Middleware().unregister(voipConfig);

  Future<bool> get isMuted => _phoneLib.audio.isMicrophoneMuted;

  Future<void> toggleMute() => _phoneLib.audio.toggleMute();

  Future<void> toggleHold() => _phoneLib.actions.toggleHold();

  Future<void> routeAudio(AudioRoute route) =>
      _phoneLib.audio.routeAudio(route);

  Future<AudioState> get audioState => _phoneLib.audio.state;

  Future<void> routeAudioToBluetoothDevice(BluetoothAudioRoute route) =>
      _phoneLib.audio.routeAudioToBluetoothDevice(route);

  Future<void> beginTransfer(String number) =>
      _phoneLib.actions.beginAttendedTransfer(number.normalize());

  Future<void> mergeTransferCalls() =>
      _phoneLib.actions.completeAttendedTransfer();
}

// This class should not keep any state of it's own.
class _Middleware with Loggable {
  final _service = dependencyLocator<MiddlewareService>();

  final _getUser = GetUserUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _getDndSetting = GetSettingUseCase<DndSetting>();

  final _storageRepository = dependencyLocator<StorageRepository>();
  final _operatingSystemInfoRepository =
      dependencyLocator<OperatingSystemInfoRepository>();

  String? get _token => _storageRepository.pushToken;

  VoipConfig? get _config => _storageRepository.voipConfig;

  Future<void> register(VoipConfig? voipConfig) async {
    logger.info('Registering..');

    final dnd = await _getDndSetting();

    if (dnd.value == true) {
      unregister(voipConfig);
      logger.info('Not registering as user has enabled DND');
      return;
    }

    if (voipConfig?.sipUserId == null) {
      logger.info('Registration cancelled: No SIP user ID set');
      return;
    }

    final user = await _getUser(latest: false);

    if (_token == null) {
      logger.info('Registration cancelled: No token');
      return;
    }

    final buildInfo = await _getBuildInfo();

    final name = user!.email;
    final token = _token!;
    final sipUserId = voipConfig!.sipUserId;
    final osVersion = await _operatingSystemInfoRepository
        .getOperatingSystemInfo()
        .then((i) => i.version);
    final clientVersion = buildInfo.version;
    final app = buildInfo.packageName;

    final response = Platform.isAndroid
        ? await _service.postAndroidDevice(
            name: name,
            token: token,
            sipUserId: sipUserId,
            osVersion: osVersion,
            clientVersion: clientVersion,
            app: app,
          )
        : Platform.isIOS
            ? await _service.postAppleDevice(
                name: name,
                token: token,
                sipUserId: sipUserId,
                osVersion: osVersion,
                clientVersion: clientVersion,
                app: app,
                sandbox: inDebugMode,
              )
            : throw UnsupportedError(
                'Unsupported platform: ${Platform.operatingSystem}',
              );

    if (!response.isSuccessful) {
      logger.warning(
        'Registration failed: ${response.statusCode} ${response.error}',
      );
      return;
    }

    _storageRepository.voipConfig = voipConfig;

    logger.info('Registered!');
  }

  Future<void> unregister(VoipConfig? voipConfig) async {
    assert(voipConfig?.sipUserId != null);

    logger.info('Unregistering..');

    // This is possible if the user logs out before the token has been received.
    if (_token == null) {
      logger.warning('No token, not unregistering');
      return;
    }

    final token = _token!;
    final sipUserId = voipConfig!.sipUserId;
    final app = await _getBuildInfo().then((i) => i.packageName);

    final response = Platform.isAndroid
        ? await _service.deleteAndroidDevice(
            token: token,
            sipUserId: sipUserId,
            app: app,
          )
        : Platform.isIOS
            ? await _service.deleteAppleDevice(
                token: token,
                sipUserId: sipUserId,
                app: app,
              )
            : throw UnsupportedError(
                'Unsupported platform: ${Platform.operatingSystem}',
              );

    if (!response.isSuccessful) {
      logger.warning(
        'Unregistering failed: ${response.statusCode} ${response.error}',
      );
      return;
    }

    _storageRepository.voipConfig = null;

    logger.info('Unregistered!');
  }

  // ignore: avoid_positional_boolean_parameters
  void respond(RemoteMessage remoteMessage, bool available) async {
    logger.info('Responding to middleware..');

    if (_config?.sipUserId == null) {
      logger.info('Responding cancelled: SIP user id is null');
      return;
    }

    // While we should have unregistered from the middleware if the user
    // enables DND, it is possible the unregister request failed. This will
    // ensure that the user does not receive a call in this scenario.
    final dnd = await _getDndSetting();

    if (dnd.value == true) {
      available = false;
      logger.warning('Overriding available to false as user has enabled DND.');
    }

    final response = await _service.callResponse(
      uniqueKey: remoteMessage.data['unique_key'] as String,
      available: available.toString(),
      messageStartTime: remoteMessage.data['message_start_time'].toString(),
      sipUserId: _config!.sipUserId,
    );

    if (!response.isSuccessful) {
      logger.warning(
        'Responding failed: ${response.statusCode} ${response.error}',
      );
      return;
    }

    logger.info('Responded to middleware');
  }

  void tokenReceived(String token) {
    logger.info('Token received');

    _storageRepository.pushToken = token;

    register(_config);
  }
}

Future<void> _initialize() async {
  await initializeDependencies(ui: false);

  await EnableConsoleLoggingUseCase()();
  await EnableRemoteLoggingIfNeededUseCase()();
}

void _onLogReceived(LogLevel level, String message) {
  Logger('FlutterPhoneLib').log(level.toLoggerLevel(), message, VoipLog());
}

void _middlewareRespond(RemoteMessage message, bool available) =>
    _Middleware().respond(message, available);

void _middlewareTokenReceived(String token) =>
    _Middleware().tokenReceived(token);

// TODO
bool _middlewareInspect(RemoteMessage message) => true;

extension on LogLevel {
  Level toLoggerLevel() {
    if (this == LogLevel.debug) {
      return Level.FINE;
    } else if (this == LogLevel.info) {
      return Level.INFO;
    } else if (this == LogLevel.warning) {
      return Level.WARNING;
    } else if (this == LogLevel.error) {
      return Level.SEVERE;
    } else {
      throw UnsupportedError('Unknown LogLevel: $this');
    }
  }
}

extension on String {
  String normalize() {
    return replaceAll(RegExp(r'\s'), '');
  }
}
