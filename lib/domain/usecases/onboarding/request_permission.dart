import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';
import '../../entities/permission_status.dart';

import '../../repositories/permission.dart';
import '../../entities/permission.dart';

class RequestPermissionUseCase
    extends UseCase<PermissionStatus, RequestPermissionUseCaseParams> {
  final PermissionRepository _permissionRepository;

  RequestPermissionUseCase(this._permissionRepository);

  @override
  Future<Stream<PermissionStatus>> buildUseCaseStream(
    RequestPermissionUseCaseParams params,
  ) async {
    final controller = StreamController<PermissionStatus>();

    final status = await _permissionRepository.enablePermission(
      params.permission,
    );

    controller.add(status);
    unawaited(controller.close());

    return controller.stream;
  }
}

class RequestPermissionUseCaseParams {
  final Permission permission;

  RequestPermissionUseCaseParams(this.permission);
}
