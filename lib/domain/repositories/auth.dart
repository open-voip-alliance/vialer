import '../entities/system_user.dart';

abstract class AuthRepository {
  Future<bool> authenticate(String email, String password);

  Future<bool> isAuthenticated();

  SystemUser get currentUser;

  /// If [currentPassword] is null, assumes the [currentUser.password] is set,
  /// and will clear it after the call.
  Future<bool> changePassword(String newPassword, {String currentPassword});
}
