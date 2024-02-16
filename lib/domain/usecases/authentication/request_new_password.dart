import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:vialer/global.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
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
