import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import '../entities/permission.dart' as domain;
import '../entities/permission_status.dart' as domain;
import 'mappers/permission.dart';
import 'mappers/permission_status.dart';

class PermissionRepository {
  Future<domain.PermissionStatus> getPermissionStatus(
    domain.Permission permission,
  ) async {
    if (permission == domain.Permission.contacts) {
      return domain.PermissionStatus.granted;
    }
    final phonePermissionStatus = await permission.toThirdPartyEntity().status;

    return phonePermissionStatus.toDomainEntity();
  }

  Future<domain.PermissionStatus> requestPermission(
    domain.Permission permission,
  ) async {
    if (permission == domain.Permission.contacts) {
      return domain.PermissionStatus.granted;
    }
    final mappedPermission = permission.toThirdPartyEntity();

    final status = await mappedPermission.request();
    return status.toDomainEntity();
  }

  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }
}
