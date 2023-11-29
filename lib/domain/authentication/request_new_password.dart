import 'package:vialer/lib/global.dart';
import 'package:injectable/injectable.dart';
import 'authentication_repository.dart';
import 'dart:async';
import '../use_case.dart';

@injectable
class RequestNewPasswordUseCase extends UseCase {
  final AuthRepository _authRepository;

  RequestNewPasswordUseCase(this._authRepository, this._metricsRepository);

  Future<bool> call({
    required String email,
  }) async {
    final success = await _authRepository.requestNewPassword(
      email: email,
    );
    track('request-new-password');
    return success;
  }
}
