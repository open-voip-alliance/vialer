import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/permission_status.dart' as domain;

domain.PermissionStatus mapPermissionStatusToDomainPermissionStatus(
  PermissionStatus status,
) {
  switch (status) {
    case PermissionStatus.granted:
      return domain.PermissionStatus.granted;

    case PermissionStatus.denied:
      return domain.PermissionStatus.denied;

    case PermissionStatus.neverAskAgain:
    case PermissionStatus.restricted:
    case PermissionStatus.disabled:
    case PermissionStatus.unknown:
    default:
      return domain.PermissionStatus.unavailable;
  }
}
