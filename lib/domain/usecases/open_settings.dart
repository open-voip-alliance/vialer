import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class OpenSettingsAppUseCase extends FutureUseCase<bool> {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  @override
  Future<bool> call() => _permissionRepository.openAppSettings();
}
