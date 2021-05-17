import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class OpenSettingsAppUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<bool> call() => _permissionRepository.openAppSettings();
}
