import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_voip_config.freezed.dart';
part 'user_voip_config.g.dart';

@freezed
class AppAccount with _$AppAccount {
  const factory AppAccount({
    @JsonKey(name: 'appaccount_account_id', fromJson: _sipUserIdFromJson)
    required String sipUserId,
    @JsonKey(name: 'appaccount_password') required String password,
    @JsonKey(name: 'appaccount_use_encryption') required bool useEncryption,
    @JsonKey(name: 'appaccount_use_opus') required bool useOpus,
  }) = _AppAccount;

  factory AppAccount.fromJson(Map<String, dynamic> json) =>
      _$AppAccountFromJson(json);

  static AppAccount? serializeFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    if (json['appaccount_password'] == null) return null;

    return _$AppAccountFromJson(json);
  }

  static Map<String, dynamic>? serializeToJson(AppAccount? config) =>
      config?.toJson();
}

String _sipUserIdFromJson(dynamic json) =>
    json is String ? json : json?.toString() ?? '';

extension NullableAppAccount on AppAccount? {
  String get sipUserId => this?.sipUserId ?? '';

  String get password => this?.password ?? '';

  bool get useEncryption => this?.useEncryption ?? false;

  bool get useOpus => this?.useOpus ?? false;
}
