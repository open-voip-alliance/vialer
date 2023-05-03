import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../voipgrid/user_voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class UserVoipConfigRepository with Loggable {
  UserVoipConfigRepository(this._service);
  final VoipgridService _service;

  Future<UserVoipConfig?> get() async {
    final response = await _service.getMobileProfile();

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch VoipConfig');
      throw RequestException(response.statusCode);
    }

    final body = response.body!;

    if (!body.hasVoipConfig) {
      logger.info('This user does not have an app account configured.');
      return null;
    }

    return UserVoipConfig.serializeFromJson(body);
  }

  Future<String?> getSelectedWebphoneAccountId() async {
    final response = await _service.getWebphoneSelectedAccount();

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Selected Webphone Account Id');
      throw RequestException(response.statusCode);
    }

    return response.body!['id'].toString();
  }
}

extension on Map<String, dynamic> {
  bool get hasVoipConfig => this['appaccount_account_id'] != null;
}

class RequestException implements Exception {
  const RequestException(this.code);

  final int code;

  @override
  String toString() => 'Request failed with code: [$code]';
}
