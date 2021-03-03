import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_user.dart';

class ChangePasswordUseCase extends FutureUseCase<void> {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _getUser = GetUserUseCase();

  @override
  Future<void> call({
    String email,
    @required String currentPassword,
    @required String newPassword,
  }) async {
    email ??= await _getUser(latest: false).then((u) => u.email);

    await _authRepository.changePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
