import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_voip_config.freezed.dart';
part 'user_voip_config.g.dart';

@freezed
class UserVoipConfig with _$UserVoipConfig {
  const factory UserVoipConfig({
    @JsonKey(name: 'appaccount_account_id', fromJson: _sipUserIdFromJson)
        required String sipUserId,
    @JsonKey(name: 'appaccount_password') required String password,
    @JsonKey(name: 'appaccount_use_encryption') required bool useEncryption,
    @JsonKey(name: 'appaccount_use_opus') required bool useOpus,
  }) = _UserVoipConfig;

  factory UserVoipConfig.fromJson(Map<String, dynamic> json) =>
      _$UserVoipConfigFromJson(json);

  static UserVoipConfig? serializeFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    if (json['appaccount_password'] == null) return null;

    return _$UserVoipConfigFromJson(json);
  }

  static Map<String, dynamic>? serializeToJson(UserVoipConfig? config) =>
      config?.toJson();
}

String _sipUserIdFromJson(dynamic json) =>
    json is String ? json : json?.toString() ?? '';

extension NullableUserVoipConfig on UserVoipConfig? {
  String get sipUserId => this?.sipUserId ?? '';

  String get password => this?.password ?? '';

  bool get useEncryption => this?.useEncryption ?? false;

  bool get useOpus => this?.useOpus ?? false;
}
