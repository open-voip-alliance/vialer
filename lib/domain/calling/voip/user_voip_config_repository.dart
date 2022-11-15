import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../voipgrid/user_voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class UserVoipConfigRepository with Loggable {
  final VoipgridService _service;

  UserVoipConfigRepository(this._service);

  Future<UserVoipConfig?> get() async {
    final response = await _service.getMobileProfile();

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch VoipConfig');
      return null;
    }

    return UserVoipConfig.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
