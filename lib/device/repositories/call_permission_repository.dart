import 'package:permission_handler/permission_handler.dart';

import '../mappers/permission_status_mapper.dart';

import '../../domain/entities/onboarding/permission_status.dart' as domain;
import '../../domain/repositories/call_permission_repository.dart';

class DeviceCallPermissionRepository extends CallPermissionRepository {
  @override
  Future<domain.PermissionStatus> getPermissionStatus() async {
    final callPermissionStatus =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);

    return mapPermissionStatusToDomainPermissionStatus(callPermissionStatus);
  }

  @override
  Future<bool> enablePermission() async {
    final permissions = await PermissionHandler().requestPermissions(
      [PermissionGroup.phone],
    );

    final status = permissions[PermissionGroup.phone];

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
