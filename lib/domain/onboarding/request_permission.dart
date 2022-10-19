import 'dart:async';

import '../../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';
import '../user/permissions/permission.dart';
import '../user/permissions/permission_repository.dart';
import '../user/permissions/permission_status.dart';

class RequestPermissionUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();
  final _envRepository = dependencyLocator<EnvRepository>();

  Future<PermissionStatus> call({required Permission permission}) async {
    if (await _envRepository.inTest) {
      // During integration tests we don't actually request permissions, they
      // are either accepted already or not needed, and in the case of
      // battery optimizations blocks the whole test (it can't be granted
      // beforehand like other permissions).
      return PermissionStatus.granted;
    }

    return await _permissionRepository.requestPermission(permission);
  }
}
