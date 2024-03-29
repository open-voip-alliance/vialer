import 'dart:async';
import 'dart:io';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/data/models/calling/voip/unable_to_initialize_phone_lib.dart';
import 'package:vialer/domain/usecases/calling/voip/prepare_voip_preferences.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/usecases/user/get_build_info.dart';
import '../../../../presentation/util/loggable.dart';
import '../../../API/calling/middleware/middleware_service.dart';
import '../../../models/user/brand.dart';
import '../../../models/user/info/build_info.dart';
import '../../../models/user/user.dart';
import '../../../models/voipgrid/app_account.dart';
import '../../../models/voipgrid/client_voip_config.dart';
import '../../legacy/storage.dart';

@lazySingleton
class VoipRepository with Loggable {
  final _service = dependencyLocator<MiddlewareService>();

  final _getBuildInfo = GetBuildInfoUseCase();

  final _storageRepository = dependencyLocator<StorageRepository>();
  late final _prepareVoipPreferences =
      dependencyLocator<PrepareVoipPreferences>();

  String? get _token => _storageRepository.pushToken;

  PhoneLib? __phoneLib;

  Future<PhoneLib> get _phoneLib {
    if (__phoneLib == null) {
      logger.warning(
        'PhoneLib was accessed and not initialized, initializing now',
      );

      if (_startUpUser == null ||
          _startUpClientConfig == null ||
          _startUpBrand == null ||
          _startUpBuildInfo == null) {
        logger.severe(
          'Not possible to initialize PhoneLib, '
          'there are no cached startup values',
        );

        throw UnableToInitializePhoneLibException();
      }

      return initializeAndStart(
        user: _startUpUser!,
        clientConfig: _startUpClientConfig!,
        brand: _startUpBrand!,
        buildInfo: _startUpBuildInfo!,
      ).then((_) => __phoneLib!);
    }

    return Future.sync(() => __phoneLib!);
  }

  var _hasStartedCompleter = Completer<bool>();

  Future<bool> get hasStarted => _hasStartedCompleter.future;

  // We pass through events so app level subscribers don't have to resubscribe
  // if we stop and start the PhoneLib.
  final _eventsController = StreamController<Event>.broadcast();
  StreamSubscription<Event>? _eventsSubscription;

  // Start-up values.
  User? _startUpUser;
  ClientVoipConfig? _startUpClientConfig;
  Brand? _startUpBrand;
  BuildInfo? _startUpBuildInfo;

  bool _initializingAndStarting = false;

  Future<void> initializeAndStart({
    required User user,
    required ClientVoipConfig clientConfig,
    required Brand brand,
    required BuildInfo buildInfo,
  }) async {
    if (_initializingAndStarting) {
      await hasStarted;
      return;
    }

    if (_hasStartedCompleter.isCompleted && await hasStarted) {
      logger.info(
        'PhoneLib is already initialized and has started, not doing anything',
      );
      return;
    }

    _initializingAndStarting = true;

    _startUpUser = user;
    _startUpClientConfig = clientConfig;
    _startUpBrand = brand;
    _startUpBuildInfo = buildInfo;

    final userConfig = user.appAccount!;

    final preferences = await _prepareVoipPreferences();

    /// Returns true if successfully initialized, false otherwise.
    Future<bool> initialize({bool firstTry = true}) async {
      final auth = await _createAuth(userConfig, clientConfig);
      try {
        __phoneLib = await initializePhoneLib((builder) {
          builder
            ..auth = auth
            ..preferences = preferences;

          return ApplicationSetup(
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

          return initialize(firstTry: false);
        }
      }

      return true;
    }

    if (!await initialize()) return;

    /// Returns true if successfully started, false otherwise.
    Future<bool> start({bool firstTry = true}) async {
      try {
        await __phoneLib!.start(
          await _prepareVoipPreferences(),
          await _createAuth(userConfig, clientConfig),
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

          return start(firstTry: false);
        }
      }

      return true;
    }

    if (!await start()) {
      _hasStartedCompleter.complete(false);
      return;
    }

    _eventsSubscription = __phoneLib!.events.listen(_eventsController.add);

    _hasStartedCompleter.complete(true);
    logger.info('PhoneLib started');

    _initializingAndStarting = false;
  }

  Future<Auth> _createAuth(
    AppAccount appAccount,
    ClientVoipConfig clientConfig,
  ) async =>
      Auth(
        username: appAccount.sipUserId,
        password: appAccount.password,
        domain: clientConfig.sipUrl.toString(),
        port: appAccount.useEncryption ? 5061 : 5060,
        secure: appAccount.useEncryption,
      );

  // We refer to the backing field `__phoneLib` instead of
  // the getter `_phoneLib`, because if for some reason the phone lib was not
  // initialized, we don't want to do that now (which will happen if _phoneLib
  // is accessed and it wasn't initialized). So we refer to the backing field
  // and close it if it's initialized, otherwise we do nothing.
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await __phoneLib?.close();
    __phoneLib = null;
    _hasStartedCompleter = Completer<bool>();
  }

  Future<void> call(String number) async =>
      (await _phoneLib).call(number.normalize());

  Future<void> stop() async {
    if (_hasStartedCompleter.isCompleted && await hasStarted) {
      await (await _phoneLib).stop();
    }
  }

  Future<void> unregister(AppAccount? appAccount) async {
    assert(appAccount?.sipUserId != null, 'No sipUserId present');

    logger.info('Unregistering..');

    // This is possible if the user logs out before the token has been received.
    if (_token == null) {
      logger.warning('No token, not unregistering');
      return;
    }

    if (appAccount?.sipUserId == null) {
      logger.warning('Unable to unregister without a [sipUserId]');
      return;
    }

    final token = _token!;
    final sipUserId = appAccount!.sipUserId;
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

    logger.info('Unregistered!');
  }

  Future<void> answerCall() async => (await _phoneLib).actions.answer();

  Future<void> refreshPreferences(User user) async {
    if (_startUpUser != null) {
      (await _phoneLib).updatePreferences(await _prepareVoipPreferences());
    }
  }

  Future<Call?> get activeCall async => (await _phoneLib).calls.active;

  Future<CallSessionState> get sessionState async =>
      (await _phoneLib).sessionState;

  Future<void> endCall() async => (await _phoneLib).actions.end();

  Future<void> sendDtmf(String dtmf) async =>
      (await _phoneLib).actions.sendDtmf(dtmf);

  Stream<Event> get events => _eventsController.stream;

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

  Future<void> performEchoCancellationCalibration() async =>
      (await _phoneLib).performEchoCancellationCalibration();
}

extension on String {
  String normalize() {
    return replaceAll(RegExp(r'\s'), '');
  }
}
