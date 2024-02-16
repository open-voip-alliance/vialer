import 'dart:async';

import '../../../data/models/user/permissions/permission.dart';
import '../../../data/models/user/permissions/permission_status.dart';
import '../../../data/repositories/env.dart';
import '../../../data/repositories/user/permissions/permission_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class RequestPermissionUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();
  final _envRepository = dependencyLocator<EnvRepository>();

  Future<PermissionStatus> call({required Permission permission}) async {
    if (_envRepository.inTest) {
      // During integration tests we don't actually request permissions, they
      // are either accepted already or not needed, and in the case of
      // battery optimizations blocks the whole test (it can't be granted
      // beforehand like other permissions).
      return PermissionStatus.granted;
    }

    return _permissionRepository.requestPermission(permission);
  }
}
