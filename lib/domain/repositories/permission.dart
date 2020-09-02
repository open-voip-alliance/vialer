import 'package:permission_handler/permission_handler.dart';

import 'mappers/permission_status.dart';

import '../entities/permission.dart' as domain;
import '../entities/permission_status.dart' as domain;
import 'mappers/permission.dart';

class PermissionRepository {
  Future<domain.PermissionStatus> getPermissionStatus(
    domain.Permission permission,
  ) async {
    final callPermissionStatus = await permission.toThirdPartyEntity().status;

    return callPermissionStatus.toDomainEntity();
  }

  Future<domain.PermissionStatus> enablePermission(
    domain.Permission permission,
  ) async {
    final mappedPermission = permission.toThirdPartyEntity();

    final status = await mappedPermission.request();
    return status.toDomainEntity();
  }
}
