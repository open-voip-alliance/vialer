import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../authentication/is_authenticated.dart';
import '../../voipgrid/client_voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class ClientVoipConfigRepository with Loggable {
  final VoipgridService _service;

  final _isAuthenticated = IsAuthenticated();

  ClientVoipConfigRepository(this._service);

  late final _fallbackServerConfig = ClientVoipConfig.fallback();

  Future<ClientVoipConfig> get() async {
    if (!_isAuthenticated()) {
      // The user isn't logged in, so retrieving it from the API will fail.
      // So get the branded urls as fallback.
      return _fallbackServerConfig;
    }

    final response = await _service.getMiddleware();

    if (response.body == null) {
      logFailedResponse(response, name: 'Fetch Server Config');
      // Use branded urls as fallback.
      return _fallbackServerConfig;
    }

    return ClientVoipConfig.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
