import 'package:chopper/chopper.dart';

import '../entities/system_user.dart';
import 'mappers/client_call_record.dart';
import 'services/voipgrid.dart';

class VoipgridPermissionsRepository {
  final VoipgridService _service;

  VoipgridPermissionsRepository(this._service);

  Future<PermissionResult> hasPermission({
    required VoipgridPermission type,
    required SystemUser user,
  }) {
    switch (type) {
      case VoipgridPermission.clientCalls:
        return _service
            .getClientCalls(
              limit: 1,
              offset: 0,
              from: DateTime.now().asVoipgridFormat,
              to: DateTime.now().asVoipgridFormat,
            )
            .then(_handle);
      case VoipgridPermission.mobileNumberFallback:
        return _service
            .getUserSettings(
              clientId: user.clientId.toString(),
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

enum VoipgridPermission {
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
