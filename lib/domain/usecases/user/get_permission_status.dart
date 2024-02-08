import 'dart:async';

import '../../../data/models/user/permissions/permission.dart';
import '../../../data/models/user/permissions/permission_status.dart';
import '../../../data/repositories/colltacts/contact_repository.dart';
import '../../../data/repositories/user/permissions/permission_repository.dart';
import '../../../dependency_locator.dart';
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
      unawaited(_contactRepository.cleanUp());
    }

    return status;
  }
}
