import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/usecases/user/get_brand.dart';

part 'client_voip_config.freezed.dart';
part 'client_voip_config.g.dart';

@freezed
class ClientVoipConfig with _$ClientVoipConfig {
  const factory ClientVoipConfig({
    @JsonKey(name: 'MIDDLEWARE', fromJson: _middlewareUrlFromJson)
    required Uri middlewareUrl,
    @JsonKey(name: 'SIP_TLS') required Uri sipUrl,
  }) = _ClientVoipConfig;

  factory ClientVoipConfig.fromJson(Map<String, dynamic> json) =>
      _$ClientVoipConfigFromJson(json);

  const ClientVoipConfig._();

  /// Fallback config created based on the current brand.
  factory ClientVoipConfig.fallback() {
    final brand = GetBrand()();

    return ClientVoipConfig(
      middlewareUrl: brand.middlewareUrl,
      sipUrl: brand.sipUrl,
    );
  }

  /// Whether this config is equal to [ClientVoipConfig.fallback].
  bool get isFallback => this == ClientVoipConfig.fallback();

  static Map<String, dynamic> serializeToJson(ClientVoipConfig config) =>
      config.toJson();
}

Uri _middlewareUrlFromJson(String json) =>
    Uri.parse(json.startsWith('https://') ? json : 'https://$json');
