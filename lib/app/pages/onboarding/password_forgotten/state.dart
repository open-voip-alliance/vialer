import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/domain/voipgrid/voipgrid_service.dart';
import '../../../../domain/authentication/request_new_password.dart';
import '../../../../domain/authentication/authentication_repository.dart';

part 'state.g.dart';
part 'state.freezed.dart';

@riverpod
class PasswordForgotten extends _$PasswordForgotten {
  late final _requestNewPasswordUseCase =
      RequestNewPasswordUseCase(AuthRepository(VoipgridService.create()));

  PasswordForgottenState build() {
    return PasswordForgottenState.initial();
  }

  Future<void> requestNewPassword(String email) async {
    state = PasswordForgottenState.loading();

    final success = await _requestNewPasswordUseCase.call(email: email);
    state = success
        ? PasswordForgottenState.success()
        : PasswordForgottenState.failure();
  }
}

@freezed
abstract class PasswordForgottenState with _$PasswordForgottenState {
  const factory PasswordForgottenState.initial() = Initial;
  const factory PasswordForgottenState.loading() = Loading;
  const factory PasswordForgottenState.success() = Success;
  const factory PasswordForgottenState.failure() = Failure;
}
