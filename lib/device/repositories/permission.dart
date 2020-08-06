import 'package:permission_handler/permission_handler.dart';

import '../mappers/permission_status.dart';

import '../../domain/entities/permission.dart' as domain;
import '../../domain/entities/permission_status.dart' as domain;
import '../../domain/repositories/permission.dart';
import '../mappers/permission.dart';

class DevicePermissionRepository extends PermissionRepository {
  @override
  Future<domain.PermissionStatus> getPermissionStatus(
    domain.Permission permission,
  ) async {
    final callPermissionStatus =
        await PermissionHandler().checkPermissionStatus(
      mapDomainPermissionToPermissionGroup(permission),
    );

    return mapPermissionStatusToDomainPermissionStatus(callPermissionStatus);
  }

  @override
  Future<domain.PermissionStatus> enablePermission(
    domain.Permission permission,
  ) async {
    final group = mapDomainPermissionToPermissionGroup(permission);
    final permissions = await PermissionHandler().requestPermissions([group]);

    return mapPermissionStatusToDomainPermissionStatus(permissions[group]);
  }
}
