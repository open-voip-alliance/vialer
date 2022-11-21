import 'dart:async';

import '../../app/util/loggable.dart';
import '../use_case.dart';
import '../voipgrid/user_voip_config.dart';
import 'get_latest_user.dart';
import 'permissions/user_permissions.dart';
import 'settings/settings.dart';
import 'user.dart';

class GetLatestLoggedInUserUseCase extends UseCase with Loggable {
  final _getLatestUser = GetLatestUserUseCase();

  /// Use this instead of [GetLatestUserUseCase] at places the user is
  /// guaranteed to be logged in.
  Future<User> call() => _getLatestUser().then((u) => u!);
}

// Some quality of life extensions for Future<User> and its properties
// which is returned from the use case.
extension FutureUser on Future<User> {
  Future<Settings> get settings => then((u) => u.settings);

  Future<UserPermissions> get permissions => then((u) => u.permissions);

  Future<UserVoipConfig?> get voip => then((u) => u.voip);
}

extension FutureSettings on Future<Settings> {
  Future<T> get<T extends Object>(SettingKey<T> key) => then((s) => s.get(key));

  Future<T?> getOrNull<T extends Object>(SettingKey<T> key) =>
      then((s) => s.getOrNull(key));
}
