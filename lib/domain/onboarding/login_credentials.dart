abstract class LoginCredentials {
  const LoginCredentials();
}

class UserProvidedCredentials extends LoginCredentials {
  final String email;
  final String password;
  final String? twoFactorCode;

  const UserProvidedCredentials({
    required this.email,
    required this.password,
    this.twoFactorCode,
  });
}

class ImportedLegacyAppCredentials extends LoginCredentials {
  final String token;
  final String email;

  const ImportedLegacyAppCredentials(
    this.token,
    this.email,
  );
}
