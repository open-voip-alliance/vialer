import 'dart:async';

import '../entities/voip_config.dart';
import 'services/voipgrid.dart';

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
