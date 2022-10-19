import 'dart:async';

import '../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import 'authentication_repository.dart';

class ChangePasswordUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _getUser = GetLoggedInUserUseCase();

  Future<void> call({
    String? email,
    required String currentPassword,
    required String newPassword,
  }) async {
    email ??= _getUser().email;

    await _authRepository.changePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
