import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_voip_config.g.dart';

@JsonSerializable()
class UserVoipConfig extends Equatable {
  /// Must include a default while there are existing users with cached
  /// VoipConfig, can be removed at a later date.
  @JsonKey(name: 'allow_appaccount_voip_calling', defaultValue: true)
  final bool isAllowedCalling;

  @JsonKey(name: 'appaccount_account_id', fromJson: _sipUserIdFromJson)
  final String sipUserId;

  @JsonKey(name: 'appaccount_password')
  final String password;

  @JsonKey(name: 'appaccount_use_encryption')
  final bool useEncryption;

  @JsonKey(name: 'appaccount_use_opus')
  final bool useOpus;

  const UserVoipConfig({
    required this.isAllowedCalling,
    required this.sipUserId,
    required this.password,
    required this.useEncryption,
    required this.useOpus,
  });

  @override
  List<Object?> get props => [
        isAllowedCalling,
        sipUserId,
        password,
        useEncryption,
        useOpus,
      ];

  @override
  String toString() => '$runtimeType('
      'isAllowedCalling: $isAllowedCalling, '
      'sipUserId: $sipUserId, '
      'useEncryption: $useEncryption, '
      'useOpus: $useOpus)';

  static UserVoipConfig? fromJson(Map<String, dynamic>? json) =>
      json != null ? _$UserVoipConfigFromJson(json) : null;

  static Map<String, dynamic>? toJson(UserVoipConfig? value) =>
      value != null ? _$UserVoipConfigToJson(value) : null;
}

String _sipUserIdFromJson(dynamic json) =>
    json is String ? json : json?.toString() ?? '';

extension NullableUserVoipConfig on UserVoipConfig? {
  bool get isAllowedCalling => this?.isAllowedCalling == true;

  String get sipUserId => this?.sipUserId ?? '';

  String get password => this?.password ?? '';

  bool get useEncryption => this?.useEncryption == true;

  bool get useOpus => this?.useOpus == true;
}
