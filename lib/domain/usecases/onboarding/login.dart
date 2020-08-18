import 'dart:async';

import 'package:meta/meta.dart';

import '../../use_case.dart';
import '../../repositories/auth.dart';

class LoginUseCase extends FutureUseCase<bool> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<bool> call({
    @required String email,
    @required String password,
  }) =>
      _authRepository.authenticate(email, password);
}
