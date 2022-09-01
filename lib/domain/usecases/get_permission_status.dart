import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/permission.dart';
import '../entities/permission_status.dart';
import '../repositories/contact.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class GetPermissionStatusUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();
  final _contactRepository = dependencyLocator<ContactRepository>();

  Future<PermissionStatus> call({
    required Permission permission,
  }) async {
    final status = await _permissionRepository.getPermissionStatus(permission);

    // If the contact permission is ever denied we need to ensure our contacts
    // cache is properly cleaned up.
    if (permission == Permission.contacts &&
        status != PermissionStatus.granted) {
      _contactRepository.cleanUp();
    }

    return status;
  }
}
