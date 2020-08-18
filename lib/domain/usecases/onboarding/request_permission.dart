import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../use_case.dart';

import '../../entities/permission_status.dart';
import '../../entities/permission.dart';
import '../../repositories/permission.dart';

class RequestPermissionUseCase extends FutureUseCase<PermissionStatus> {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  @override
  Future<PermissionStatus> call({@required Permission permission}) =>
      _permissionRepository.enablePermission(permission);
}
