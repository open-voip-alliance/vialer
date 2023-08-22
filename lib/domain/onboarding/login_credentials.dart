import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_credentials.freezed.dart';

@freezed
sealed class LoginCredentials with _$LoginCredentials {
  const factory LoginCredentials.userProvided({
    required String email,
    required String password,
    String? twoFactorCode,
  }) = UserProvidedCredentials;

  const factory LoginCredentials.importedFromLegacyApp(
    String token,
    String email,
  ) = ImportedLegacyAppCredentials;
}
