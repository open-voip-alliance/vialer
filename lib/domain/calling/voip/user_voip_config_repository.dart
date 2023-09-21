import 'dart:async';

import '../../../app/util/loggable.dart';
import '../../voipgrid/user_voip_config.dart';
import '../../voipgrid/voipgrid_service.dart';

class AppAccountRepository with Loggable {
  AppAccountRepository(this._service);
  final VoipgridService _service;

  Future<AppAccount?> get() async {
    final response = await _service.getMobileProfile();

    // If we get a 404, there is no app account so we should return null
    // rather than throwing an exception.
    if (response.statusCode == 404) return null;

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch VoipConfig');
      throw RequestException(response.statusCode);
    }

    final body = response.body!;

    if (!body.hasVoipConfig) {
      logger.info('This user does not have an app account configured.');
      return null;
    }

    return AppAccount.serializeFromJson(body);
  }

  Future<String?> getSelectedWebphoneAccountId() async {
    final response = await _service.getWebphoneSelectedAccount();

    // If we get a 404, there is no webphone account so we should return null
    // rather than throwing an exception.
    if (response.statusCode == 404) return null;

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
