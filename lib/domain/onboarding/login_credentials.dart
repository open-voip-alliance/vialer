abstract class LoginCredentials {
  const LoginCredentials();
}

class UserProvidedCredentials extends LoginCredentials {
  const UserProvidedCredentials({
    required this.email,
    required this.password,
    this.twoFactorCode,
  });

  final String email;
  final String password;
  final String? twoFactorCode;
}

class ImportedLegacyAppCredentials extends LoginCredentials {
  const ImportedLegacyAppCredentials(
    this.token,
    this.email,
  );

  final String token;
  final String email;
}
