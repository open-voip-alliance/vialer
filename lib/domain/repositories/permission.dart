import 'package:permission_handler/permission_handler.dart';

import 'mappers/permission_status.dart';

import '../entities/permission.dart' as domain;
import '../entities/permission_status.dart' as domain;
import 'mappers/permission.dart';

class PermissionRepository {
  Future<domain.PermissionStatus> getPermissionStatus(
    domain.Permission permission,
  ) async {
    final callPermissionStatus =
        await PermissionHandler().checkPermissionStatus(
      mapDomainPermissionToPermissionGroup(permission),
    );

    return mapPermissionStatusToDomainPermissionStatus(callPermissionStatus);
  }

  Future<domain.PermissionStatus> enablePermission(
    domain.Permission permission,
  ) async {
    final group = mapDomainPermissionToPermissionGroup(permission);
    final permissions = await PermissionHandler().requestPermissions([group]);

    return mapPermissionStatusToDomainPermissionStatus(permissions[group]);
  }
}
