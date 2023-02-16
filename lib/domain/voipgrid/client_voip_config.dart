import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/get_brand.dart';

part 'client_voip_config.freezed.dart';
part 'client_voip_config.g.dart';

@freezed
class ClientVoipConfig with _$ClientVoipConfig {
  const ClientVoipConfig._();

  const factory ClientVoipConfig({
    @JsonKey(name: 'MIDDLEWARE', fromJson: _middlewareUrlFromJson)
        required Uri middlewareUrl,
    @JsonKey(name: 'SIP_UDP') required Uri unencryptedSipUrl,
    @JsonKey(name: 'SIP_TLS') required Uri encryptedSipUrl,
  }) = _ClientVoipConfig;

  static Uri _middlewareUrlFromJson(String json) =>
      Uri.parse(json.startsWith('https://') ? json : 'https://$json');

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

  factory ClientVoipConfig.fromJson(Map<String, dynamic> json) =>
      _$ClientVoipConfigFromJson(json);

  static Map<String, dynamic> serializeToJson(ClientVoipConfig config) =>
      config.toJson();
}
