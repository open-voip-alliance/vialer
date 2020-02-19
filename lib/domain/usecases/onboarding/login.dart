import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase extends UseCase<bool, LoginUseCaseParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(LoginUseCaseParams params) async {
    final controller = StreamController<bool>();

    final success = await _authRepository.authenticate(
      params.email,
      params.password,
    );

    controller.add(success);
    controller.close();

    return controller.stream;
  }
}

class LoginUseCaseParams {
  final String email;
  final String password;

  LoginUseCaseParams(this.email, this.password);
}
