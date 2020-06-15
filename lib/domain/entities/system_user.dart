class SystemUser {
  static const _uuidKey = 'uuid';
  static const _emailKey = 'email';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _appAccountKey = 'app_account';

  static const _tokenKey = 'token';

  final String uuid;

  final String email;

  /// Only used for caching during onboarding, should _not_ be saved, ever.
  final String password;

  final String firstName;
  final String lastName;

  final String token;

  final Uri _appAccount;

  String get appAccountId => _appAccount?.pathSegments?.lastWhere(
        (p) => p.isNotEmpty,
        orElse: () => null,
      );

  SystemUser({
    this.uuid,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.token,
    Uri appAccount,
  }) : _appAccount = appAccount;

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      uuid: json[_uuidKey],
      email: json[_emailKey],
      firstName: json[_firstNameKey],
      lastName: json[_lastNameKey],
      token: json[_tokenKey],
      appAccount:
          json[_appAccountKey] != null ? Uri.parse(json[_appAccountKey]) : null,
    );
  }

  Map<String, dynamic> toJson({bool includeToken = false}) {
    return {
      _uuidKey: uuid,
      _emailKey: email,
      _firstNameKey: firstName,
      _lastNameKey: lastName,
      if (includeToken) _tokenKey: token,
      _appAccountKey: _appAccount.toString(),
    };
  }

  SystemUser copyWith({
    String uuid,
    String email,
    String password,
    String firstName,
    String lastName,
    String token,
    Uri appAccount,
  }) {
    return SystemUser(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      appAccount: appAccount ?? _appAccount,
    );
  }
}
