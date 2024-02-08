import 'dart:async';

import '../../../../data/repositories/user/permissions/permission_repository.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';

class OpenSettingsAppUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<bool> call() => _permissionRepository.openAppSettings();
}
