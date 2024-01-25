import 'dart:async';

import 'package:vialer/data/models/user/refresh/user_refresh_task.dart';
import 'package:vialer/data/models/user/settings/setting_changed.dart';
import 'package:vialer/data/models/user/user.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';
import 'package:vialer/domain/usecases/user/refresh/refresh_user.dart';
import 'package:vialer/domain/usecases/user/settings/force_update_setting.dart';

import '../../../../../../data/repositories/metrics/metrics.dart';
import '../../../../data/models/event/event_bus.dart';
import '../../../../data/models/user/settings/listeners/refresh_voip_preferences.dart';
import '../../../../data/models/user/settings/listeners/setting_change_listener.dart';
import '../../../../data/models/user/settings/listeners/start_voip_on_use_voip_enabled.dart';
import '../../../../data/models/user/settings/listeners/update_availability.dart';
import '../../../../data/models/user/settings/listeners/update_dnd_status.dart';
import '../../../../data/models/user/settings/listeners/update_mobile_number.dart';
import '../../../../data/models/user/settings/listeners/update_outgoing_number.dart';
import '../../../../data/models/user/settings/listeners/update_remote_logging.dart';
import '../../../../data/models/user/settings/listeners/update_use_mobile_number_as_fallback.dart';
import '../../../../data/models/user/settings/settings.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class ChangeSettingUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _eventBus = dependencyLocator<EventBus>();
  final _getCurrentUser = GetLoggedInUserUseCase();

  final _listeners = <SettingChangeListener>[
    UpdateDestinationListener(),
    UpdateMobileNumberListener(),
    UpdateOutgoingNumberListener(),
    UpdateRemoteLoggingListener(),
    UpdateUseMobileNumberAsFallbackListener(),
    StartVoipOnUseVoipEnabledListener(),
    UpdateAvailabilityStatus(),
    RefreshVoipPreferences(),
  ];

  Future<SettingChangeResult> call<T extends Object>(
    SettingKey<T> key,
    T value, {
    bool track = true,
    bool force = false,
  }) async {
    final user = _getCurrentUser();
    final oldSettingValue = user.settings.get(key);

    if (value == oldSettingValue && !force) {
      logger.info(
        'Skipping updating this setting as it is the same as stored.',
      );

      return SettingChangeResult.changed;
    }

    await ForceUpdateSetting()(key, value);

    final result = await _callListeners(key, value);

    if (result.log) {
      logger.info('Set $key to $value');
    }

    if (track) {
      _metricsRepository.trackSettingChange(key, value.toString());
    }

    // If we ever fail, we want to make sure we have fetched the latest data
    // so the user isn't out-of-sync with the server.
    if (result.sync || result.failed) {
      await RefreshUser()(tasksToPerform: UserRefreshTask.all);
    }

    _eventBus.broadcast(SettingChangedEvent(key, oldSettingValue, value));

    return result.toSettingChangeResult();
  }

  Future<SettingChangeListenResult> _callListeners<T extends Object>(
    SettingKey<T> key,
    T value,
  ) async {
    final user = GetLoggedInUserUseCase()();

    for (final listener in _listeners) {
      if (!listener.shouldHandle(key)) continue;

      final futureOrResult = listener.applySettingsSideEffects(user, value);

      return futureOrResult is Future ? await futureOrResult : futureOrResult;
    }

    return SettingChangeListenResult(log: false, sync: false, failed: false);
  }
}

enum SettingChangeResult {
  changed,
  failed;

  bool get wasChanged => this == SettingChangeResult.changed;
}

extension on SettingChangeListenResult {
  SettingChangeResult toSettingChangeResult() =>
      this.failed ? SettingChangeResult.failed : SettingChangeResult.changed;
}
