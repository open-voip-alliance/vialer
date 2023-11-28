import 'authentication_repository.dart';
import 'dart:async';
import '../use_case.dart';

class RequestNewPasswordUseCase extends UseCase {
  final AuthRepository _authRepository;

  RequestNewPasswordUseCase(this._authRepository);

  Future<bool> call({
    required String email,
  }) =>
      _authRepository.requestNewPassword(
        email: email,
      );
}
