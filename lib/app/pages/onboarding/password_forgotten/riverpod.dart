import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/dependency_locator.dart';

import '../../../../domain/authentication/request_new_password.dart';
import '../../../../domain/authentication/authentication_repository.dart';
import '../../../util/loggable.dart';
import '../../../../domain/authentication/validate_account.dart';

import 'state.dart';

part 'riverpod.g.dart';

@riverpod
class PasswordForgotten extends _$PasswordForgotten {
  late final _authRepository = dependencyLocator<AuthRepository>();

  late final _requestNewPasswordUseCase =
      RequestNewPasswordUseCase(_authRepository);

  PasswordForgottenState build() => PasswordForgottenState.initial();

  Future<void> requestNewPassword(String email) async {
    logger.info('Requesting new password');

    final hasValidEmailFormat =
        await ValidateAccount.hasValidEmailFormat(email);

    if (!hasValidEmailFormat) {
      state = PasswordForgottenState.notSubmitted(
        hasValidEmailFormat: hasValidEmailFormat,
      );
      return;
    }

    state = PasswordForgottenState.loading();

    final success = await _requestNewPasswordUseCase.call(email: email);
    state = success
        ? PasswordForgottenState.success()
        : PasswordForgottenState.failure();
  }
}
