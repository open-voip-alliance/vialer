import 'package:permission_handler/permission_handler.dart';

import '../../entities/permission.dart' as domain;

extension PermissionMapper on domain.Permission {
  Permission toThirdPartyEntity() {
    switch (this) {
      case domain.Permission.phone:
        return Permission.phone;

      case domain.Permission.contacts:
        return Permission.contacts;

      case domain.Permission.microphone:
        return Permission.microphone;

      case domain.Permission.bluetooth:
        return Permission.bluetoothConnect;

      case domain.Permission.ignoreBatteryOptimizations:
        return Permission.ignoreBatteryOptimizations;

      default:
        throw UnsupportedError(
          'Domain Permission has no equivalent package Permission: $this',
        );
    }
  }
}
