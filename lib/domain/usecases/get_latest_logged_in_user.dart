import 'dart:async';

import '../../app/util/loggable.dart';
import '../entities/settings/settings.dart';
import '../entities/user.dart';
import '../entities/user_permissions.dart';
import '../use_case.dart';
import 'get_latest_user.dart';

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
}

extension FutureSettings on Future<Settings> {
  Future<T> get<T extends Object>(SettingKey<T> key) => then((s) => s.get(key));

  Future<T?> getOrNull<T extends Object>(SettingKey<T> key) =>
      then((s) => s.getOrNull(key));
}
