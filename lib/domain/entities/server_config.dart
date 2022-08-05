import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_config.g.dart';

@JsonSerializable()
class ServerConfig extends Equatable {
  @JsonKey(name: 'MIDDLEWARE', fromJson: _middlewareUrlFromJson)
  final String middlewareUrl;

  @JsonKey(name: 'SIP_UDP')
  final String unencryptedSipUrl;

  @JsonKey(name: 'SIP_TLS')
  final String encryptedSipUrl;

  static String _middlewareUrlFromJson(String json) =>
       json.startsWith('https://') ? json : 'https://$json';

  const ServerConfig({
    required this.middlewareUrl,
    required this.unencryptedSipUrl,
    required this.encryptedSipUrl,
  });

  @override
  List<Object?> get props => [
    middlewareUrl,
    unencryptedSipUrl,
    encryptedSipUrl,
  ];

  @override
  String toString() => '$runtimeType('
      'middlewareUrl: $middlewareUrl, '
      'unencryptedSipUrl: $unencryptedSipUrl, '
      'encryptedSipUrl: $encryptedSipUrl)';

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ServerConfigToJson(this);
}