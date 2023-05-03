import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../onboarding/is_onboarded.dart';
import '../../voipgrid/client_voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class ClientVoipConfigRepository with Loggable {
  ClientVoipConfigRepository(this._service);

  final VoipgridService _service;

  final _isOnboarded = IsOnboarded();

  late final _fallbackServerConfig = ClientVoipConfig.fallback();

  Future<ClientVoipConfig> get() async {
    if (!_isOnboarded()) {
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

    return ClientVoipConfig.fromJson(response.body!);
  }
}
