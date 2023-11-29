import 'package:vialer/domain/metrics/metrics.dart';
import 'package:injectable/injectable.dart';
import 'authentication_repository.dart';
import 'dart:async';
import '../use_case.dart';

@injectable
class RequestNewPasswordUseCase extends UseCase {
  final AuthRepository _authRepository;
  final MetricsRepository _metricsRepository;

  RequestNewPasswordUseCase(this._authRepository, this._metricsRepository);

  Future<bool> call({
    required String email,
  }) async {
    final success = await _authRepository.requestNewPassword(
      email: email,
    );

    _metricsRepository.track('request-new-password');
    return success;
  }
}
