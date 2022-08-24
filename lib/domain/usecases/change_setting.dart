import 'dart:async';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../events/event_bus.dart';
import '../events/show_client_calls_setting_enabled.dart';
import '../repositories/destination.dart';
import '../repositories/metrics.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'change_availability.dart';
import 'change_mobile_number.dart';
import 'client_calls/purge_local_call_records.dart';
import 'disable_remote_logging.dart';
import 'enable_remote_logging.dart';
import 'get_mobile_number.dart';
import 'get_settings.dart';
import 'increment_app_rating_survey_action_count.dart';
import 'refresh_voip.dart';
import 'register_to_voip_middleware.dart';
import 'start_voip.dart';
import 'unregister_to_voip_middleware.dart';

class ChangeSettingUseCase extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _destinationRepository = dependencyLocator<DestinationRepository>();

  final _eventBus = dependencyLocator<EventBus>();

  final _getSettings = GetSettingsUseCase();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();
  final _disableRemoteLogging = DisableRemoteLoggingUseCase();
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();
  final _unregisterToVoipMiddleware = UnregisterToVoipMiddlewareUseCase();
  final _startVoip = StartVoipUseCase();
  final _refreshVoip = RefreshVoipUseCase();
  final _changeMobileNumber = ChangeMobileNumberUseCase();
  final _getMobileNumber = GetMobileNumberUseCase();
  final _changeAvailability = ChangeAvailabilityUseCase();
  final _incrementAppRatingActionCount =
      IncrementAppRatingSurveyActionCountUseCase();
  final _purgeLocalCallRecords = PurgeLocalCallRecords();

  Future<void> call({required Setting setting, bool remote = true}) async {
    if (setting is AvailabilitySetting) {
      final availability = await _destinationRepository.getLatestAvailability();
      final oldDestinationInfo = availability?.selectedDestinationInfo ?? null;
      final newDestinationInfo = setting.value!.selectedDestinationInfo ?? null;

      if (oldDestinationInfo != newDestinationInfo) {
        // Only log the destination, since the whole availability object
        // contains too much privacy sensitive information.
        logger.info('Changed ${setting.runtimeType} '
            'to ${setting.value!.selectedDestinationInfo}');
      }
    }

    if (setting is RemoteLoggingSetting) {
      if (setting.value == true) {
        await _enableRemoteLogging();
      } else {
        await _disableRemoteLogging();
      }
    } else if (remote && setting is AvailabilitySetting) {
      await _changeAvailability(
        destination: setting.value!.selectedDestinationInfo!,
      );
    }

    if (!setting.mutable) {
      throw UnsupportedError(
        'Vialer error: Unsupported operation: '
        'Don\'t save an immutable setting.',
      );
    }

    if (remote && setting is MobileNumberSetting) {
      var mobileNumber = setting.value;
      await _changeMobileNumber(mobileNumber: mobileNumber);

      mobileNumber = (await _getMobileNumber(latest: true))!;
      setting = MobileNumberSetting(mobileNumber);
    }

    final settings = await _getSettings();
    final hasSettingValueChanged = _didSettingChange(settings, setting);

    final newSettings = List<Setting>.from(settings)
      ..removeWhere((e) => e.runtimeType == setting.runtimeType)
      ..add(setting);

    // We only want to save mutable settings.
    await _storageRepository
        .setSettings(newSettings.where((s) => s.mutable).toList());

    // We do this after writing the setting so setting checks work.
    if (setting is UseVoipSetting && setting.value == true) {
      try {
        await _registerToVoipMiddleware();
        await _startVoip();
        // ignore: avoid_catching_errors
      } on Error {}
    } else if (setting is UsePhoneRingtoneSetting ||
        setting is ShowCallsInNativeRecentsSetting) {
      await _refreshVoip();
    } else if (setting is DndSetting) {
      // This will happen in the background because we do not need to rely
      // on this to have happened when the user changes the setting.
      if (setting.value) {
        _unregisterToVoipMiddleware();
      } else {
        _registerToVoipMiddleware();
      }
    } else if (setting is ShowClientCallsSetting) {
      if (setting.value == false) {
        _purgeLocalCallRecords(reason: PurgeReason.disabled);
      }

      _eventBus.broadcast(ShowClientCallsSettingChanged(setting.value));
    }

    if (hasSettingValueChanged && setting.shouldTrack) {
      logger.info('Set ${setting.runtimeType} to ${setting.value}');

      _metricsRepository.track(
        '${setting.asMetricKeyName}_changed',
        setting.asMetricProperties,
      );
    }

    _incrementAppRatingActionCount();
  }

  bool _didSettingChange(
    List<Setting> currentSettings,
    Setting newSetting,
  ) =>
      currentSettings
          .where(
            (setting) => setting.runtimeType == newSetting.runtimeType,
          )
          .first
          .value !=
      newSetting.value;
}
