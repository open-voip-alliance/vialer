import 'package:dartx/dartx.dart';

import '../../app/util/loggable.dart';
import '../user/user.dart';
import '../vialer.dart';
import 'voipgrid_service.dart';

class UserPermissionsRepository with Loggable {
  final VoipgridService _service;

  UserPermissionsRepository(this._service);

  static const _permissionsMapping = {
    'cdr.view_record': UserPermission.clientCalls,
    'permission.change_user': UserPermission.changeMobileNumberFallback,
    'permission.view_user': UserPermission.viewMobileNumberFallback,
    // There is only one temporary redirect permission, it is not separated
    // between viewing and changing.
    'business_availability.change_temporary_redirect':
        UserPermission.temporaryRedirect,
    'voicemail.view_voicemail': UserPermission.viewVoicemail,
    'phoneaccount.change_phoneaccount': UserPermission.changeVoipAccount,
  };

  Future<List<UserPermission>> getGrantedPermissions({
    required User user,
  }) async {
    final response = await _service.getVoipgridPermissions();

    if (!response.isSuccessful) {
      logFailedResponse(response);
      throw UnableToRetrievePermissionsException();
    }

    return (response.body['permissions'] as List<dynamic>)
        .map(
          (permission) => _permissionsMapping.containsKey(permission)
              ? _permissionsMapping[permission]
              : null,
        )
        .filterNotNull()
        .toList(growable: false);
  }
}

enum UserPermission {
  clientCalls,
  viewMobileNumberFallback,
  changeMobileNumberFallback,
  temporaryRedirect,
  viewVoicemail,
  changeVoipAccount,
}

class UnableToRetrievePermissionsException extends VialerException {}
