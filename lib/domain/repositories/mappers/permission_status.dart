import 'package:permission_handler/permission_handler.dart';

import '../../entities/permission_status.dart' as domain;

extension PermissionStatusMapper on PermissionStatus {
  domain.PermissionStatus toDomainEntity() {
    switch (this) {
      case PermissionStatus.granted:
        return domain.PermissionStatus.granted;

      case PermissionStatus.denied:
        return domain.PermissionStatus.denied;

      case PermissionStatus.permanentlyDenied:
        return domain.PermissionStatus.permanentlyDenied;

      case PermissionStatus.restricted:
        return domain.PermissionStatus.restricted;

      case PermissionStatus.undetermined:
      default:
        return domain.PermissionStatus.undetermined;
    }
  }
}
