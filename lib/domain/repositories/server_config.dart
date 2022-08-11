import 'dart:async';

import '../entities/server_config.dart';
import '../usecases/get_encrypted_sip_url.dart';
import '../usecases/get_is_authenticated.dart';
import '../usecases/get_middleware_base_url.dart';
import '../usecases/get_unencrypted_sip_url.dart';
import 'services/voipgrid.dart';

class ServerConfigRepository {
  final VoipgridService _service;

  final _isAuthenticated = GetIsAuthenticatedUseCase();
  final _getMiddlewareUrl = GetMiddlewareBaseUrlUseCase();
  final _getEncryptedSipUrl = GetEncryptedSipUrlUseCase();
  final _getUnencryptedSipUrl = GetUnencryptedSipUrlUseCase();

  ServerConfigRepository(this._service);

  Future<ServerConfig> get() async {
    final isAuthenticated = await _isAuthenticated();
    if (!isAuthenticated) {
      // The user isn't logged in, so retrieving it from the API will fail.
      // So get the branded urls as fallback.
      return _fallbackServerConfig;
    }

    final response = await _service.getMiddleware();

    if (response.body == null) {
      // Use branded urls as fallback.
      return _fallbackServerConfig;
    }

    return ServerConfig.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  ServerConfig get _fallbackServerConfig => ServerConfig(
        middlewareUrl: _getMiddlewareUrl(),
        unencryptedSipUrl: _getUnencryptedSipUrl(),
        encryptedSipUrl: _getEncryptedSipUrl(),
      );
}
