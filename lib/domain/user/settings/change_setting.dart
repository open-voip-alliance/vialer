import 'dart:async';

import 'package:vialer/domain/user/get_logged_in_user.dart';
import 'package:vialer/domain/user/refresh/refresh_user.dart';
import 'package:vialer/domain/user/refresh/user_refresh_task.dart';
import 'package:vialer/domain/user/settings/force_update_setting.dart';
import 'package:vialer/domain/user/settings/setting_changed.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../dependency_locator.dart';
import '../../event/event_bus.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import 'listeners/setting_change_listener.dart';
import 'listeners/refresh_voip_preferences.dart';
import 'listeners/start_voip_on_use_voip_enabled.dart';
import 'listeners/update_availability.dart';
import 'listeners/update_dnd_status.dart';
import 'listeners/update_mobile_number.dart';
import 'listeners/update_outgoing_number.dart';
import 'listeners/update_remote_logging.dart';
import 'listeners/update_use_mobile_number_as_fallback.dart';
import 'settings.dart';

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
    UpdateDndStatus(),
    RefreshVoipPreferences(),
  ];

  Future<SettingChangeResult> call<T extends Object>(
    SettingKey<T> key,
    T value, {
    bool track = true,
  }) async {
    final user = _getCurrentUser();
    final oldSettingValue = user.settings.get(key);

    final beforeResult = await _callListeners(key, value, ListenerType.before);

    await ForceUpdateSetting()(key, value);

    final afterResult = await _callListeners(key, value, ListenerType.after);

    final result = beforeResult + afterResult;

    if (result.log) {
      logger.info('Set $key to $value');
    }

    if (track) {
      _metricsRepository.trackSettingChange(key, value);
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
    ListenerType type,
  ) async {
    final user = GetLoggedInUserUseCase()();

    for (final listener in _listeners) {
      if (!listener.shouldHandle(key)) continue;

      final futureOrResult = type == ListenerType.before
          ? listener.preStore(user, value)
          : listener.postStore(user, value);

      return futureOrResult is Future ? await futureOrResult : futureOrResult;
    }

    return SettingChangeListenResult(log: false, sync: false, failed: false);
  }
}

enum ListenerType {
  before,
  after,
}

enum SettingChangeResult {
  /// The value was already the same as it was supposed to change to.
  unchanged,
  changed,
  failed,
}

extension on SettingChangeListenResult {
  SettingChangeResult toSettingChangeResult() =>
      this.failed ? SettingChangeResult.failed : SettingChangeResult.changed;
}
