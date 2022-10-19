import 'dart:async';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/permissions/permission_repository.dart';

class OpenSettingsAppUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<bool> call() => _permissionRepository.openAppSettings();
}
