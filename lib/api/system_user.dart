class SystemUser {
  final String email;

  final String firstName;
  final String lastName;

  final Uri _appAccount;

  String get appAccountId => _appAccount.pathSegments.lastWhere(
        (p) => p.isNotEmpty,
      );

  SystemUser({
    this.email,
    this.firstName,
    this.lastName,
    Uri appAccount,
  }) : _appAccount = appAccount;

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      appAccount: Uri.parse(json['app_account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'app_account': _appAccount.toString(),
    };
  }
}
