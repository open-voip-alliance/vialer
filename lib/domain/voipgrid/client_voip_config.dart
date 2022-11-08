import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../user/get_brand.dart';

part 'client_voip_config.g.dart';

@JsonSerializable()
class ClientVoipConfig extends Equatable {
  @JsonKey(name: 'MIDDLEWARE', fromJson: _middlewareUrlFromJson)
  final Uri middlewareUrl;

  @JsonKey(name: 'SIP_UDP')
  final Uri unencryptedSipUrl;

  @JsonKey(name: 'SIP_TLS')
  final Uri encryptedSipUrl;

  static Uri _middlewareUrlFromJson(String json) =>
      Uri.parse(json.startsWith('https://') ? json : 'https://$json');

  const ClientVoipConfig({
    required this.middlewareUrl,
    required this.unencryptedSipUrl,
    required this.encryptedSipUrl,
  });

  /// Fallback config created based on the current brand.
  factory ClientVoipConfig.fallback() {
    final brand = GetBrand()();

    return ClientVoipConfig(
      middlewareUrl: brand.middlewareUrl,
      unencryptedSipUrl: brand.unencryptedSipUrl,
      encryptedSipUrl: brand.encryptedSipUrl,
    );
  }

  /// Whether this config is equal to [ClientVoipConfig.fallback].
  bool get isFallback => this == ClientVoipConfig.fallback();

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

  static ClientVoipConfig fromJson(Map<String, dynamic> json) =>
      _$ClientVoipConfigFromJson(json);

  static Map<String, dynamic> toJson(ClientVoipConfig value) =>
      _$ClientVoipConfigToJson(value);
}
