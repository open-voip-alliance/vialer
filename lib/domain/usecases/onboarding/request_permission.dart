import 'dart:async';

import 'package:meta/meta.dart';

import '../../use_case.dart';

import '../../entities/permission_status.dart';
import '../../entities/permission.dart';
import '../../repositories/permission.dart';

class RequestPermissionUseCase extends FutureUseCase<PermissionStatus> {
  final PermissionRepository _permissionRepository;

  RequestPermissionUseCase(this._permissionRepository);

  @override
  Future<PermissionStatus> call({@required Permission permission}) =>
      _permissionRepository.enablePermission(permission);
}
