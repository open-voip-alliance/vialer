import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_user.dart';

class ChangePasswordUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _getUser = GetUserUseCase();

  Future<void> call({
    String? email,
    required String currentPassword,
    required String newPassword,
  }) async {
    email ??= await _getUser(latest: false).then((u) => u!.email);

    await _authRepository.changePassword(
      email: email!,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
