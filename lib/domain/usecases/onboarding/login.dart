import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/auth.dart';
import '../../repositories/storage.dart';
import '../../use_case.dart';

class LoginUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<bool> call({
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.authenticate(email, password);
    if (user == null) {
      return false;
    }

    _storageRepository.systemUser = user;

    return true;
  }
}
