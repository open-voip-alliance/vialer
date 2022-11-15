import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../calling/voip/refresh_voip.dart';
import '../../event/event_bus.dart';
import '../../feedback/increment_app_rating_survey_action_count.dart';
import '../../legacy/storage.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import '../../user/get_latest_logged_in_user.dart';
import '../../user/get_logged_in_user.dart';
import '../synchronized_user_editor.dart';
import 'app_setting.dart';
import 'call_setting.dart';
import 'listeners/change_registration_on_dnd_change.dart';
import 'listeners/setting_change_listener.dart';
import 'listeners/start_voip_on_use_voip_enabled.dart';
import 'listeners/update_availability.dart';
import 'listeners/update_mobile_number.dart';
import 'listeners/update_outgoing_number.dart';
import 'listeners/update_remote_logging.dart';
import 'listeners/update_use_mobile_number_as_fallback.dart';
import 'setting_changed.dart';
import 'settings.dart';

class ChangeSettingsUseCase extends UseCase
    with Loggable, SynchronizedUserEditor {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _eventBus = dependencyLocator<EventBus>();

  final _refreshVoip = RefreshVoipUseCase();
  final _incrementAppRatingActionCount =
      IncrementAppRatingSurveyActionCountUseCase();
  final _getCurrentUser = GetLoggedInUserUseCase();
  final _getLatestUser = GetLatestLoggedInUserUseCase();

  final _listeners = <SettingChangeListener>[
    UpdateAvailabilityListener(),
    UpdateMobileNumberListener(),
    UpdateOutgoingNumberListener(),
    UpdateRemoteLoggingListener(),
    UpdateUseMobileNumberAsFallbackListener(),
    StartVoipOnUseVoipEnabledListener(),
    ChangeRegistrationOnDndChange(),
  ];

  Future<ChangeSettingsResult> call(Settings settings) => editUser(
        () async {
          var user = _getCurrentUser();
          final currentSettings = user.settings;

          final diff = currentSettings.diff(settings);

          // Nothing has changed, return.
          if (diff.isEmpty) return const ChangeSettingsResult();

          // List of settings whose changes were rejected or otherwise failed.
          final failed = <SettingKey>{};

          // If a setting changes that has an API side effect, it's good
          // practice to retrieve the value from the API again, to be
          // completely in sync, instead of assuming that the sent value
          // to the API is correct, even on success.
          final needSync = <SettingKey>{};

          // Settings whose changes should not be logged. If a setting
          // should have a custom log message, or if the change shouldn't
          // be logged at all,add it to this list.
          // If you want a custom log message, log it manually.
          final skipLogging = <SettingKey>{};

          Future<void> _notifyListeners(
            Iterable<MapEntry<SettingKey, Object>> entries, {
            required bool before,
          }) async {
            for (final entry in entries) {
              final key = entry.key;
              final value = entry.value;

              for (final listener in _listeners) {
                if (listener.key != key) continue;

                final futureOrResult = before
                    ? listener.beforeStore(user, value)
                    : listener.afterStore(user, value);

                final result = futureOrResult is Future
                    ? await futureOrResult
                    : futureOrResult;

                if (!result.log) {
                  skipLogging.add(key);
                }

                if (result.sync) {
                  needSync.add(key);
                  assert(
                    before,
                    'No sync will happen after storing. Use `beforeStore`',
                  );
                }

                if (result.failed) {
                  failed.add(key);
                }
              }
            }
          }

          // This is a function, because the second listener run might add
          // more failed setting changes.
          Settings getChanged() => diff.getAll(diff.keys.difference(failed));

          await _notifyListeners(diff.entries, before: true);

          // Retrieve the latest user with latest remote setting values, and
          // copy them into the settings result.
          if (needSync.isNotEmpty) {
            user = await _getLatestUser();
            settings = settings.copyFrom(user.settings.getAll(needSync));
          }

          _storageRepository.user = user.copyWith(
            settings: user.settings.copyFrom(settings),
          );

          // We do this after storing the settings so setting checks work.

          await _notifyListeners(getChanged().entries, before: false);

          if (diff.hasAnyKeyOf([
            CallSetting.usePhoneRingtone,
            AppSetting.showCallsInNativeRecents,
          ])) {
            await _refreshVoip();
          }

          for (final entry in getChanged().entries) {
            final key = entry.key;
            final value = entry.value;
            final oldValue = currentSettings.get(key);

            if (!skipLogging.contains(key)) {
              logger.info('Set $key to $value');
            }

            _metricsRepository.trackSettingChange(key, value);

            _eventBus.broadcast(
              SettingChanged(key, oldValue, value),
            );
          }

          _incrementAppRatingActionCount();
          return ChangeSettingsResult(
            changed: diff.keys.where((k) => !failed.contains(k)),
            failed: failed,
          );
        },
      );
}

class ChangeSettingsResult {
  final Iterable<SettingKey> changed;

  /// Settings whose changes were rejected.
  final Iterable<SettingKey> failed;

  const ChangeSettingsResult({this.changed = const [], this.failed = const []});
}

extension FutureChangeSettingsResult on Future<ChangeSettingsResult> {
  Future<Iterable<SettingKey>> get changed => then((r) => r.changed);

  Future<Iterable<SettingKey>> get failed => then((r) => r.failed);
}
