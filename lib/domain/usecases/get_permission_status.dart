import 'dart:async';

import 'package:meta/meta.dart';

import '../entities/permission.dart';
import '../entities/permission_status.dart';
import '../repositories/permission.dart';
import '../use_case.dart';

class GetPermissionStatusUseCase extends FutureUseCase<PermissionStatus> {
  final PermissionRepository _permissionRepository;

  GetPermissionStatusUseCase(this._permissionRepository);

  @override
  Future<PermissionStatus> call({
    @required Permission permission,
  }) =>
      _permissionRepository.getPermissionStatus(permission);
}
