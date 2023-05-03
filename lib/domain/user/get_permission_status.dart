import 'dart:async';

import '../../dependency_locator.dart';
import '../colltacts/contact_repository.dart';
import '../use_case.dart';
import 'permissions/permission.dart';
import 'permissions/permission_repository.dart';
import 'permissions/permission_status.dart';

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
