import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../entities/permission.dart';
import '../../entities/permission_status.dart';
import '../../repositories/permission.dart';
import '../../use_case.dart';

class RequestPermissionUseCase extends FutureUseCase<PermissionStatus> {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  @override
  Future<PermissionStatus> call({@required Permission permission}) =>
      _permissionRepository.requestPermission(permission);
}
