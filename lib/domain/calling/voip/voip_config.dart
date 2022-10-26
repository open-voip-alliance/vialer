import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../voipgrid/voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class VoipConfigRepository with Loggable {
  final VoipgridService _service;

  VoipConfigRepository(this._service);

  Future<VoipConfig?> get() async {
    final response = await _service.getMobileProfile();

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch VoipConfig');
      return null;
    }

    return VoipConfig.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
