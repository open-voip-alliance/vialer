import 'package:dartx/dartx.dart';

class SystemUser {
  static const _uuidKey = 'uuid';
  static const _emailKey = 'email';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _appAccountKey = 'app_account';
  static const _outgoingCliKey = 'outgoing_cli';

  static const _tokenKey = 'token';

  final String uuid;

  final String email;

  final String firstName;
  final String lastName;

  final String token;

  final Uri _appAccount;

  final String outgoingCli;

  String get appAccountId => _appAccount?.pathSegments?.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  SystemUser({
    this.uuid,
    this.email,
    this.firstName,
    this.lastName,
    this.token,
    Uri appAccount,
    this.outgoingCli,
  }) : _appAccount = appAccount;

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      uuid: json[_uuidKey] as String,
      email: json[_emailKey] as String,
      firstName: json[_firstNameKey] as String,
      lastName: json[_lastNameKey] as String,
      token: json[_tokenKey] as String,
      appAccount: json[_appAccountKey] != null
          ? Uri.parse(json[_appAccountKey] as String)
          : null,
      outgoingCli: json[_outgoingCliKey] as String,
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
      _outgoingCliKey: outgoingCli,
    };
  }

  SystemUser copyWith({
    String uuid,
    String email,
    String firstName,
    String lastName,
    String token,
    Uri appAccount,
    String outgoingCli,
  }) {
    return SystemUser(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      appAccount: appAccount ?? _appAccount,
      outgoingCli: outgoingCli ?? this.outgoingCli,
    );
  }
}
