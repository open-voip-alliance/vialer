import 'dart:async';

import '../../../dependency_locator.dart';
import '../../entities/permission.dart';
import '../../entities/permission_status.dart';
import '../../repositories/permission.dart';
import '../../use_case.dart';

class RequestPermissionUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<PermissionStatus> call({required Permission permission}) =>
      _permissionRepository.requestPermission(permission);
}
