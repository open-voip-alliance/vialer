import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';

import '../../../main/util/observer.dart';

class PermissionPresenter extends Presenter {
  Function requestPermissionOnNext;

  final RequestPermissionUseCase _requestPermissionUseCase;

  PermissionPresenter(PermissionRepository permissionRepository)
      : _requestPermissionUseCase = RequestPermissionUseCase(
          permissionRepository,
        );

  void ask(Permission permission) => _requestPermissionUseCase.execute(
        Watcher(
          onNext: requestPermissionOnNext,
        ),
        RequestPermissionUseCaseParams(permission),
      );

  @override
  void dispose() {
    _requestPermissionUseCase.dispose();
  }
}
