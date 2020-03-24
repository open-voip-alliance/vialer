import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/repositories/permission.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';

class PermissionPresenter extends Presenter {
  Function requestPermissionOnNext;

  final RequestPermissionUseCase _requestPermissionUseCase;

  PermissionPresenter(PermissionRepository callPermissionRepository)
      : _requestPermissionUseCase = RequestPermissionUseCase(
          callPermissionRepository,
        );

  void ask(Permission permission) => _requestPermissionUseCase.execute(
        _PermissionObserver(this),
        RequestPermissionUseCaseParams(permission),
      );

  @override
  void dispose() {
    _requestPermissionUseCase.dispose();
  }
}

class _PermissionObserver extends Observer<bool> {
  final PermissionPresenter presenter;

  _PermissionObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(bool granted) => presenter.requestPermissionOnNext(granted);
}
