import 'dart:async';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';

class ChangePasswordUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _getUser = GetLoggedInUserUseCase();

  Future<bool> call({
    required String currentPassword,
    required String newPassword,
    String? email,
  }) async {
    email ??= _getUser().email;

    return _authRepository.changePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
