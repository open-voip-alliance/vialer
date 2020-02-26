import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../../repositories/permission.dart';
import '../../entities/onboarding/permission.dart';

class RequestPermissionUseCase
    extends UseCase<bool, RequestPermissionUseCaseParams> {
  final PermissionRepository _permissionRepository;

  RequestPermissionUseCase(this._permissionRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(
    RequestPermissionUseCaseParams params,
  ) async {
    final controller = StreamController<bool>();

    final granted = await _permissionRepository.enablePermission(
      params.permission,
    );

    controller.add(granted);
    unawaited(controller.close());

    return controller.stream;
  }
}

class RequestPermissionUseCaseParams {
  final Permission permission;

  RequestPermissionUseCaseParams(this.permission);
}
