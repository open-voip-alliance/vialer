import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import 'permission.dart' as domain;
import 'permission_status.dart' as domain;

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
  permission_handler.Permission toThirdPartyEntity() {
    switch (this) {
      case domain.Permission.phone:
        return permission_handler.Permission.phone;

      case domain.Permission.contacts:
        return permission_handler.Permission.contacts;

      case domain.Permission.microphone:
        return permission_handler.Permission.microphone;

      case domain.Permission.bluetooth:
        return permission_handler.Permission.bluetoothConnect;

      case domain.Permission.ignoreBatteryOptimizations:
        return permission_handler.Permission.ignoreBatteryOptimizations;

      case domain.Permission.notifications:
        return permission_handler.Permission.notification;
    }
  }
}

extension PermissionStatusMapper on permission_handler.PermissionStatus {
  domain.PermissionStatus toDomainEntity() {
    switch (this) {
      case permission_handler.PermissionStatus.granted:
        return domain.PermissionStatus.granted;

      case permission_handler.PermissionStatus.denied:
        return domain.PermissionStatus.denied;

      case permission_handler.PermissionStatus.permanentlyDenied:
        return domain.PermissionStatus.permanentlyDenied;

      case permission_handler.PermissionStatus.restricted:
        return domain.PermissionStatus.restricted;

      case permission_handler.PermissionStatus.limited:
        return domain.PermissionStatus.undetermined;
    }
  }
}
