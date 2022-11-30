import 'dart:async';

import 'package:meta/meta.dart';

import '../../../user/user.dart';
import '../settings.dart';

/// A listener that can execute any side effects based on a setting change.
///
/// It must not call any `[EditUser]` task, even indirectly.
abstract class SettingChangeListener<T extends Object> {
  /// Which key to listen to.
  SettingKey<T> get key;

  Future<SettingChangeListenResult> changeRemoteValue(
    Future<bool> Function() action, {
    bool log = true,
  }) async {
    final success = await action();

    return SettingChangeListenResult(
      log: log,
      sync: success,
      failed: !success,
    );
  }

  /// Before the settings are stored.
  FutureOr<SettingChangeListenResult> beforeStore(User user, T value) =>
      successResult;

  /// After the settings are stored.
  FutureOr<SettingChangeListenResult> afterStore(User user, T value) =>
      successResult;
}

@immutable
class SettingChangeListenResult {
  /// Whether to log the setting change. Set to `false`
  /// if the listener logs it themselves.
  final bool log;

  /// Whether we need to sync the setting after changing, to validate
  /// the actual final change from an API.
  final bool sync;

  /// Whether the change failed.
  final bool failed;

  const SettingChangeListenResult({
    this.log = true,
    this.sync = false,
    this.failed = false,
  });
}

const successResult = SettingChangeListenResult();
const failedResult = SettingChangeListenResult(failed: true);
