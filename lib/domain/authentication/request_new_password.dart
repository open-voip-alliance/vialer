import 'package:vialer/global.dart';
import 'package:injectable/injectable.dart';
import 'authentication_repository.dart';
import 'dart:async';
import '../use_case.dart';

@injectable
class RequestNewPassword extends UseCase {
  final AuthRepository _authRepository;

  RequestNewPassword(this._authRepository);

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
