import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voip_config.g.dart';

@JsonSerializable()
class VoipConfig extends Equatable {
  @JsonKey(name: 'allow_appaccount_voip_calling')
  final bool isAllowedCalling;

  @JsonKey(name: 'appaccount_account_id', fromJson: _sipUserIdFromJson)
  final String? sipUserId;

  @JsonKey(name: 'appaccount_password')
  final String? password;

  @JsonKey(name: 'appaccount_use_encryption')
  final bool? useEncryption;

  @JsonKey(name: 'appaccount_use_opus')
  final bool? useOpus;

  bool get isEmpty =>
      sipUserId == null &&
      password == null &&
      useEncryption == null &&
      useOpus == null;

  bool get isNotEmpty => !isEmpty;

  const VoipConfig({
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

  factory VoipConfig.fromJson(Map<String, dynamic> json) =>
      _$VoipConfigFromJson(json);

  Map<String, dynamic> toJson() => _$VoipConfigToJson(this);

  NonEmptyVoipConfig toNonEmptyConfig() => NonEmptyVoipConfig.from(this);
}

String? _sipUserIdFromJson(dynamic json) =>
    json is String ? json : json?.toString();

class NonEmptyVoipConfig extends VoipConfig {
  @override
  final String sipUserId;
  @override
  final String password;
  @override
  final bool useEncryption;
  @override
  final bool useOpus;

  NonEmptyVoipConfig.from(VoipConfig config)
      : assert(config.isNotEmpty),
        sipUserId = config.sipUserId!,
        password = config.password!,
        useEncryption = config.useEncryption!,
        useOpus = config.useOpus!,
        super(
          isAllowedCalling: config.isAllowedCalling,
          sipUserId: config.sipUserId,
          password: config.password,
          useEncryption: config.useEncryption,
          useOpus: config.useOpus,
        );
}
