import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import 'permission.dart' as domain;
import 'permission_status.dart' as domain;

@singleton
class PermissionRepository {
  Future<domain.PermissionStatus> getPermissionStatus(
    domain.Permission permission,
  ) async {
    final phonePermissionStatus = await permission.toThirdPartyEntity().status;

    return phonePermissionStatus.toDomainEntity();
  }

  Future<domain.PermissionStatus> requestPermission(
    domain.Permission permission,
  ) async {
    final mappedPermission = permission.toThirdPartyEntity();

    final status = await mappedPermission.request();
    return status.toDomainEntity();
  }

  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }
}

extension PermissionMapper on domain.Permission {
  permission_handler.Permission toThirdPartyEntity() => switch (this) {
        domain.Permission.phone => permission_handler.Permission.phone,
        domain.Permission.contacts => permission_handler.Permission.contacts,
        domain.Permission.microphone =>
          permission_handler.Permission.microphone,
        domain.Permission.bluetooth =>
          permission_handler.Permission.bluetoothConnect,
        domain.Permission.ignoreBatteryOptimizations =>
          permission_handler.Permission.ignoreBatteryOptimizations,
        domain.Permission.notifications =>
          permission_handler.Permission.notification,
      };
}

extension PermissionStatusMapper on permission_handler.PermissionStatus {
  domain.PermissionStatus toDomainEntity() => switch (this) {
        permission_handler.PermissionStatus.granted ||
        permission_handler.PermissionStatus.provisional =>
          domain.PermissionStatus.granted,
        permission_handler.PermissionStatus.denied =>
          domain.PermissionStatus.denied,
        permission_handler.PermissionStatus.permanentlyDenied =>
          domain.PermissionStatus.permanentlyDenied,
        permission_handler.PermissionStatus.restricted =>
          domain.PermissionStatus.restricted,
        permission_handler.PermissionStatus.limited =>
          domain.PermissionStatus.undetermined
      };
}
