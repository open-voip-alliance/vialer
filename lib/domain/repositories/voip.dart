import 'dart:async';
import 'dart:io';

import 'package:flutter_phone_lib/audio/bluetooth_audio_route.dart';
import 'package:flutter_phone_lib/call_session_state.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/brand.dart';
import '../entities/build_info.dart';
import '../entities/setting.dart';
import '../entities/voip_config.dart';
import '../usecases/enable_console_logging.dart';
import '../usecases/enable_remote_logging_if_needed.dart';
import '../usecases/get_allowed_voip_config.dart';
import '../usecases/get_build_info.dart';
import '../usecases/get_encrypted_sip_url.dart';
import '../usecases/get_setting.dart';
import '../usecases/get_unencrypted_sip_url.dart';
import '../usecases/get_user.dart';
import '../usecases/metrics/track_push_followed_by_call.dart';
import 'env.dart';
import 'operating_system_info.dart';
import 'services/middleware.dart';
import 'storage.dart';

class VoipRepository with Loggable {
  PhoneLib? __phoneLib;

  Future<PhoneLib> get _phoneLib {
    if (__phoneLib == null) {
      logger.warning(
        'PhoneLib was accessed and not initialized, initializing now',
      );

      return initializeAndStart(
        config: _startUpConfig!,
        brand: _startUpBrand!,
        buildInfo: _startUpBuildInfo!,
      ).then((_) => __phoneLib!);
    }

    return Future.sync(() => __phoneLib!);
  }

  final _hasStartedCompleter = Completer<bool>();

  Future<bool> get hasStarted => _hasStartedCompleter.future;

  final _getEncryptedSipUrl = GetEncryptedSipUrlUseCase();
  final _getUnencryptedSipUrl = GetUnencryptedSipUrlUseCase();

  // Start-up values.
  NonEmptyVoipConfig? _startUpConfig;
  Brand? _startUpBrand;
  BuildInfo? _startUpBuildInfo;

  bool _initializingAndStarting = false;

  Future<void> initializeAndStart({
    required NonEmptyVoipConfig config,
    required Brand brand,
    required BuildInfo buildInfo,
  }) async {
    if (_initializingAndStarting) {
      await hasStarted;
      return;
    }

    if (_hasStartedCompleter.isCompleted) {
      logger.info(
        'PhoneLib is already initialized and has started, not doing anything',
      );
      return;
    }

    _initializingAndStarting = true;

    _startUpConfig = config;
    _startUpBrand = brand;
    _startUpBuildInfo = buildInfo;

    final preferences = await _createPreferences(config);

    /// Returns true if successfully initialized, false otherwise.
    Future<bool> initialize({bool firstTry = true}) async {
      try {
        __phoneLib = await initializePhoneLib((builder) {
          builder
            ..auth = _createAuth(config)
            ..preferences = preferences;

          return ApplicationSetup(
            initialize: _initialize,
            middleware: const Middleware(
              respond: _middlewareRespond,
              tokenReceived: _middlewareTokenReceived,
              inspect: _middlewareInspect,
            ),
            onMissedCallNotificationPressed: () =>
                _missedCallNotificationPressedController.add(true),
            userAgent: '${brand.appName} '
                '${Platform.isAndroid ? 'Android' : 'iOS'} '
                'v${buildInfo.version}',
          );
        });
      } on Exception catch (e) {
        if (!firstTry) {
          logger.severe(
            'PhoneLib did not initialize, '
            'not trying again since we did already. Reason: $e',
          );

          return false;
        } else {
          logger.severe(
            'PhoneLib did not initialize, trying again. Reason: $e',
          );

          return await initialize(firstTry: false);
        }
      }

      return true;
    }

    if (!await initialize()) return;

    /// Returns true if successfully started, false otherwise.
    Future<bool> start({bool firstTry = true}) async {
      try {
        await __phoneLib!.start(
          await _createPreferences(config),
          _createAuth(config),
        );
      } on Exception catch (e) {
        if (!firstTry) {
          logger.severe(
            'PhoneLib did not start, '
            'not trying again since we did already. Reason: $e',
          );

          return false;
        } else {
          logger.severe(
            'PhoneLib did not start, trying again. Reason: $e',
          );

          return await start(firstTry: false);
        }
      }

      return true;
    }

    if (!await start()) return;

    _hasStartedCompleter.complete(true);
    logger.info('PhoneLib started');

    _initializingAndStarting = false;
  }

  Auth _createAuth(NonEmptyVoipConfig config) => Auth(
        username: config.sipUserId.toString(),
        password: config.password,
        domain: config.useEncryption
            ? _getEncryptedSipUrl()
            : _getUnencryptedSipUrl(),
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

  // We refer to the backing field `__phoneLib` instead of
  // the getter `_phoneLib`, because if for some reason the phone lib was not
  // initialized, we don't want to do that now (which will happen if _phoneLib
  // is accessed and it wasn't initialized). So we refer to the backing field
  // and stop it if it's initialized, otherwise we do nothing.
  Future<void> stop() async => __phoneLib?.stop();

  Future<void> call(String number) async =>
      (await _phoneLib).call(number.normalize());

  Future<void> answerCall() async => (await _phoneLib).actions.answer();

  Future<void> refreshPreferences(VoipConfig config) async =>
      (await _phoneLib).updatePreferences(await _createPreferences(config));

  Future<Call?> get activeCall async => (await _phoneLib).calls.active;

  Future<CallSessionState> get sessionState async =>
      (await _phoneLib).sessionState;

  Future<void> endCall() async => (await _phoneLib).actions.end();

  Future<void> sendDtmf(String dtmf) async =>
      (await _phoneLib).actions.sendDtmf(dtmf);

  Stream<Event> get events async* {
    final phoneLib = await _phoneLib;

    yield* phoneLib.events;
  }

  Future<void> register(NonEmptyVoipConfig voipConfig) =>
      _Middleware().register(voipConfig);

  Future<void> unregister(NonEmptyVoipConfig voipConfig) =>
      _Middleware().unregister(voipConfig);

  Future<bool> get isMuted async => (await _phoneLib).audio.isMicrophoneMuted;

  Future<void> toggleMute() async => (await _phoneLib).audio.toggleMute();

  Future<void> toggleHold() async => (await _phoneLib).actions.toggleHold();

  Future<void> hold() async => (await _phoneLib).actions.hold();

  Future<void> routeAudio(AudioRoute route) async =>
      (await _phoneLib).audio.routeAudio(route);

  Future<void> launchAudioRoutePicker() async =>
      (await _phoneLib).audio.launchAudioRoutePicker();

  Future<AudioState> get audioState async => (await _phoneLib).audio.state;

  Future<void> routeAudioToBluetoothDevice(BluetoothAudioRoute route) async =>
      (await _phoneLib).audio.routeAudioToBluetoothDevice(route);

  Future<void> beginTransfer(String number) async =>
      (await _phoneLib).actions.beginAttendedTransfer(number.normalize());

  Future<void> mergeTransferCalls() async =>
      (await _phoneLib).actions.completeAttendedTransfer();

  final _missedCallNotificationPressedController =
      StreamController<bool>.broadcast();

  Stream<bool> get missedCallNotificationPresses =>
      _missedCallNotificationPressedController.stream;
}

// This class should not keep any state of it's own.
class _Middleware with Loggable {
  final _service = dependencyLocator<MiddlewareService>();

  final _getUser = GetUserUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();
  final _getDndSetting = GetSettingUseCase<DndSetting>();
  final _trackPushFollowedByCall = TrackPushFollowedByCallUseCase();
  final _getVoipConfig = GetNonEmptyVoipConfigUseCase();

  final _storageRepository = dependencyLocator<StorageRepository>();
  final _operatingSystemInfoRepository =
      dependencyLocator<OperatingSystemInfoRepository>();
  final _envRepository = dependencyLocator<EnvRepository>();

  String? get _token => _storageRepository.pushToken;

  Future<NonEmptyVoipConfig> get _config => _getVoipConfig(latest: false);

  Future<void> register(NonEmptyVoipConfig? voipConfig) async {
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
    final useSandbox = await _envRepository.sandbox;

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
                sandbox: useSandbox,
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

  Future<void> unregister(NonEmptyVoipConfig? voipConfig) async {
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

    // While we should have unregistered from the middleware if the user
    // enables DND, it is possible the unregister request failed. This will
    // ensure that the user does not receive a call in this scenario.
    final dnd = await _getDndSetting();

    if (dnd.value == true) {
      available = false;
      logger.warning('Overriding available to false as user has enabled DND');
    }

    final response = await _service.callResponse(
      uniqueKey: remoteMessage.data['unique_key'] as String,
      available: available.toString(),
      messageStartTime: remoteMessage.data['message_start_time'].toString(),
      sipUserId: (await _config).sipUserId,
    );

    if (response.isSuccessful) {
      _trackPushFollowedByCall();
      logger.info('Responded to middleware');
    } else {
      logger.warning(
        'Responding failed: ${response.statusCode} ${response.error}',
      );
    }
  }

  Future<void> tokenReceived(String token) async {
    logger.info('Token received');

    _storageRepository.pushToken = token;

    register(await _config);
  }
}

Future<void> _initialize() async {
  await initializeDependencies(ui: false);

  await EnableConsoleLoggingUseCase()();
  await EnableRemoteLoggingIfNeededUseCase()();
}

void _middlewareRespond(RemoteMessage message, bool available) =>
    _Middleware().respond(message, available);

void _middlewareTokenReceived(String token) =>
    _Middleware().tokenReceived(token);

// TODO
bool _middlewareInspect(RemoteMessage message) => true;

extension on String {
  String normalize() {
    return replaceAll(RegExp(r'\s'), '');
  }
}
