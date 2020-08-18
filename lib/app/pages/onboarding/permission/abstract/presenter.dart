import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';

class PermissionPresenter extends Presenter {
  Function requestPermissionOnNext;

  final RequestPermissionUseCase _requestPermission;

  PermissionPresenter(PermissionRepository permissionRepository)
      : _requestPermission = RequestPermissionUseCase(
          permissionRepository,
        );

  void ask(Permission permission) =>
      _requestPermission(permission: permission).then(requestPermissionOnNext);

  @override
  void dispose() {}
}
