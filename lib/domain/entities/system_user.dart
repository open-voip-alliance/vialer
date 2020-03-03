class SystemUser {
  static const _uuidKey = 'uuid';
  static const _emailKey = 'email';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _appAccountKey = 'app_account';

  final String uuid;

  final String email;

  final String firstName;
  final String lastName;

  final Uri _appAccount;

  String get appAccountId => _appAccount.pathSegments.lastWhere(
        (p) => p.isNotEmpty,
      );

  SystemUser({
    this.uuid,
    this.email,
    this.firstName,
    this.lastName,
    Uri appAccount,
  }) : _appAccount = appAccount;

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      uuid: json[_uuidKey],
      email: json[_emailKey],
      firstName: json[_firstNameKey],
      lastName: json[_lastNameKey],
      appAccount: Uri.parse(json[_appAccountKey]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _uuidKey: uuid,
      _emailKey: email,
      _firstNameKey: firstName,
      _lastNameKey: lastName,
      _appAccountKey: _appAccount.toString(),
    };
  }
}
