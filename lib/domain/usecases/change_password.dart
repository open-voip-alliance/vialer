import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class ChangePasswordUseCase extends FutureUseCase<void> {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  Future<void> call({
    String currentPassword,
    @required String newPassword,
  }) async {
    await _authRepository.changePassword(
      newPassword,
      currentPassword: currentPassword,
    );
  }
}
