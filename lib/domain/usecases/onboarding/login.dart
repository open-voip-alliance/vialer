import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../repositories/auth.dart';
import '../../repositories/storage.dart';
import '../../use_case.dart';

class LoginUseCase extends FutureUseCase<bool> {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  @override
  Future<bool> call({
    @required String email,
    @required String password,
  }) async {
    final user = await _authRepository.authenticate(email, password);
    if (user == null) {
      return false;
    }

    _storageRepository.systemUser = user;

    return true;
  }
}
