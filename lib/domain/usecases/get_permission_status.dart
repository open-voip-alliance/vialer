import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/onboarding/permission.dart';
import '../entities/onboarding/permission_status.dart';
import '../repositories/permission.dart';

class GetPermissionStatusUseCase
    extends UseCase<PermissionStatus, GetPermissionStatusUseCaseParams> {
  final PermissionRepository _permissionRepository;

  GetPermissionStatusUseCase(this._permissionRepository);

  @override
  Future<Stream<PermissionStatus>> buildUseCaseStream(
    GetPermissionStatusUseCaseParams params,
  ) async {
    final controller = StreamController<PermissionStatus>();

    final status = await _permissionRepository.getPermissionStatus(
      params.permission,
    );

    controller.add(status);
    unawaited(controller.close());

    return controller.stream;
  }
}

class GetPermissionStatusUseCaseParams {
  final Permission permission;

  GetPermissionStatusUseCaseParams(this.permission);
}
