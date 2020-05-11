import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/storage.dart';

import '../../../../domain/usecases/call.dart';
import '../../../../domain/usecases/get_latest_dialed_number.dart';

import '../../../../domain/entities/permission.dart';
import '../../../../domain/entities/permission_status.dart';
import '../../../../domain/repositories/permission.dart';
import '../../../../domain/usecases/get_permission_status.dart';

class DialerPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function onCheckCallPermissionNext;

  Function onGetLatestDialedNumberNext;

  final CallUseCase _callUseCase;
  final GetPermissionStatusUseCase _getPermissionStatusUseCase;
  final GetLatestDialedNumber _getLatestDialedNumberUseCase;

  DialerPresenter(
    CallRepository callRepository,
    PermissionRepository permissionRepository,
    StorageRepository storageRepository,
  )   : _callUseCase = CallUseCase(callRepository),
        _getPermissionStatusUseCase = GetPermissionStatusUseCase(
          permissionRepository,
        ),
        _getLatestDialedNumberUseCase = GetLatestDialedNumber(
          storageRepository,
        );

  void call(String destination) {
    _callUseCase.execute(
      _CallUseCaseObserver(this),
      CallUseCaseParams(destination),
    );
  }

  void checkCallPermission() {
    _getPermissionStatusUseCase.execute(
      _GetPermissionStatusUseCaseObserver(this),
      GetPermissionStatusUseCaseParams(Permission.phone),
    );
  }

  void getLatestNumber() => _getLatestDialedNumberUseCase.execute(
        _GetLatestDialedNumberUseObserver(this),
      );

  @override
  void dispose() {
    _callUseCase.dispose();
  }
}

class _CallUseCaseObserver extends Observer<void> {
  final DialerPresenter presenter;

  _CallUseCaseObserver(this.presenter);

  @override
  void onComplete() => presenter.callOnComplete();

  @override
  void onError(dynamic e) => presenter.callOnError(e);

  @override
  void onNext(_) {}
}

class _GetPermissionStatusUseCaseObserver extends Observer<PermissionStatus> {
  final DialerPresenter presenter;

  _GetPermissionStatusUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(PermissionStatus status) =>
      presenter.onCheckCallPermissionNext(status);
}

class _GetLatestDialedNumberUseObserver extends Observer<String> {
  final DialerPresenter presenter;

  _GetLatestDialedNumberUseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(_) {}

  @override
  void onNext(String number) => presenter.onGetLatestDialedNumberNext(number);
}
