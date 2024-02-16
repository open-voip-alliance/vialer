import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../../domain/usecases/authentication/request_new_password.dart';
import '../../../../../../domain/usecases/authentication/validate_email.dart';
import 'state.dart';

part 'riverpod.g.dart';

@riverpod
class PasswordForgotten extends _$PasswordForgotten {
  late final _requestNewPassword = dependencyLocator<RequestNewPassword>();
  late final _validateEmail = dependencyLocator<ValidateEmail>();

  PasswordForgottenState build() => PasswordForgottenState.initial();

  Future<void> requestNewPassword(String email) async {
    logger.info('Requesting new password');

    final hasValidEmailFormat = await _validateEmail(email);

    if (!hasValidEmailFormat) {
      state = PasswordForgottenState.notSubmitted(
        hasValidEmailFormat: hasValidEmailFormat,
      );
      return;
    }

    state = PasswordForgottenState.loading();

    final success = await _requestNewPassword(email: email);
    state = success
        ? PasswordForgottenState.success()
        : PasswordForgottenState.failure();
  }
}
