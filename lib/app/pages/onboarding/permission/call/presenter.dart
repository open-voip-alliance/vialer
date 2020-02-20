import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import '../../../../../domain/repositories/call_permission.dart';

import '../../../../../domain/usecases/onboarding/request_call_permission.dart';

class CallPermissionPresenter extends Presenter {
  Function requestCallPermissionOnNext;

  final RequestCallPermissionUseCase _requestCallPermissionUseCase;

  CallPermissionPresenter(CallPermissionRepository callPermissionRepository)
      : _requestCallPermissionUseCase = RequestCallPermissionUseCase(
          callPermissionRepository,
        );

  void ask() => _requestCallPermissionUseCase.execute(
        _CallPermissionObserver(this),
      );

  @override
  void dispose() {
    _requestCallPermissionUseCase.dispose();
  }
}

class _CallPermissionObserver extends Observer<bool> {
  final CallPermissionPresenter presenter;

  _CallPermissionObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(bool granted) => presenter.requestCallPermissionOnNext(granted);
}
