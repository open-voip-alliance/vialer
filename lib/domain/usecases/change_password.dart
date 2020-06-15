import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../repositories/auth.dart';

class ChangePasswordUseCase extends UseCase<void, ChangePasswordUseCaseParams> {
  final AuthRepository _authRepository;

  ChangePasswordUseCase(this._authRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(
    ChangePasswordUseCaseParams params,
  ) async {
    final controller = StreamController<void>();

    await _authRepository.changePassword(
      params.newPassword,
      currentPassword: params.currentPassword,
    );

    unawaited(controller.close());

    return controller.stream;
  }
}

class ChangePasswordUseCaseParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordUseCaseParams({
    this.currentPassword,
    @required this.newPassword,
  });
}
