import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voip_config.g.dart';

@JsonSerializable()
class VoipConfig extends Equatable {
  @JsonKey(name: 'appaccount_account_id', fromJson: _sipUserIdFromJson)
  final String sipUserId;

  @JsonKey(name: 'appaccount_password')
  final String password;

  @JsonKey(name: 'appaccount_use_encryption')
  final bool useEncryption;

  @JsonKey(name: 'appaccount_use_opus')
  final bool useOpus;

  const VoipConfig({
    this.sipUserId,
    this.password,
    this.useEncryption,
    this.useOpus,
  });

  @override
  List<Object> get props => [
        sipUserId,
        password,
        useEncryption,
        useOpus,
      ];

  @override
  String toString() => '$runtimeType('
      'id: $sipUserId, '
      'useEncryption: $useEncryption, '
      'useOpus: $useOpus)';

  factory VoipConfig.fromJson(Map<String, dynamic> json) =>
      _$VoipConfigFromJson(json);

  Map<String, dynamic> toJson() => _$VoipConfigToJson(this);
}

String _sipUserIdFromJson(dynamic json) =>
    json is String ? json : json.toString();
