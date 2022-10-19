import 'dart:async';

import '../../voipgrid/voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class VoipConfigRepository {
  final VoipgridService _service;

  VoipConfigRepository(this._service);

  Future<VoipConfig> get() async {
    final response = await _service.getMobileProfile();

    return VoipConfig.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
