import 'package:dartx/dartx.dart';

import '../../app/util/loggable.dart';
import '../legacy/storage.dart';
import '../user/user.dart';
import '../vialer.dart';
import 'voipgrid_service.dart';

class UserPermissionsRepository with Loggable {
  final VoipgridService _service;
  final StorageRepository _storage;

  UserPermissionsRepository(this._service, this._storage);

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

    final grantedPermissions = response.body['permissions'] as List<dynamic>;

    // Storing the raw permissions so we can submit these to metrics later.
    _storage.grantedVoipgridPermissions =
        grantedPermissions.toRawPermissionsList();

    return grantedPermissions
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
