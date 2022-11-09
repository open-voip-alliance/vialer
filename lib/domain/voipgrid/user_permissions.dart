import 'package:chopper/chopper.dart';

import '../call_records/client/client_call_record.dart';
import '../user/user.dart';
import 'voipgrid_service.dart';

class UserPermissionsRepository {
  final VoipgridService _service;

  UserPermissionsRepository(this._service);

  Future<PermissionResult> hasPermission({
    required UserPermission type,
    required User user,
  }) {
    switch (type) {
      case UserPermission.clientCalls:
        return _service
            .getClientCalls(
              limit: 1,
              offset: 0,
              from: DateTime.now().asVoipgridFormat,
              to: DateTime.now().asVoipgridFormat,
            )
            .then(_handle);
      case UserPermission.mobileNumberFallback:
        return _service
            .getUserSettings(
              clientId: user.client.id.toString(),
              userId: user.uuid,
            )
            .then(_handle);
    }
  }

  PermissionResult _handle(Response response) {
    if (response.isSuccessful) return PermissionResult.granted;

    if (response.statusCode == 403 || response.statusCode == 401) {
      return PermissionResult.denied;
    }

    return PermissionResult.unavailable;
  }
}

enum UserPermission {
  clientCalls,
  mobileNumberFallback,
}

enum PermissionResult {
  granted,
  denied,

  /// As our method of querying permissions is to query an end-point, this might
  /// be unavailable for other reasons. In this situation we should not update
  /// the permissions.
  unavailable,
}
