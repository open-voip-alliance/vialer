import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../../entities/need_to_change_password.dart';
import '../../repositories/auth.dart';

class LoginUseCase extends UseCase<bool, LoginUseCaseParams> {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(LoginUseCaseParams params) async {
    final controller = StreamController<bool>();

    var success = false;
    try {
      success = await _authRepository.authenticate(
        params.email,
        params.password,
      );
    } on NeedToChangePassword catch(e) {
      controller.addError(e);
    }


    controller.add(success);
    unawaited(controller.close());

    return controller.stream;
  }
}

class LoginUseCaseParams {
  final String email;
  final String password;

  LoginUseCaseParams(this.email, this.password);
}
