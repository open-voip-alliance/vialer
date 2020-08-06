import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/storage.dart';

import '../../../../domain/usecases/call.dart';
import '../../../../domain/usecases/get_latest_dialed_number.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';

import '../../../../domain/entities/permission.dart';
import '../../../../domain/repositories/permission.dart';
import '../../../../domain/usecases/get_permission_status.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/usecases/get_settings.dart';

import '../util/observer.dart';

class DialerPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function onCheckCallPermissionNext;

  Function onGetLatestDialedNumberNext;

  Function onGetSettingsNext;

  final CallUseCase _callUseCase;
  final GetLatestDialedNumber _getLatestDialedNumberUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final GetPermissionStatusUseCase _getPermissionStatusUseCase;
  final RequestPermissionUseCase _requestPermissionUseCase;

  DialerPresenter(
    CallRepository callRepository,
    PermissionRepository permissionRepository,
    StorageRepository storageRepository,
    SettingRepository settingRepository,
  )   : _callUseCase = CallUseCase(callRepository),
        _getPermissionStatusUseCase = GetPermissionStatusUseCase(
          permissionRepository,
        ),
        _getLatestDialedNumberUseCase = GetLatestDialedNumber(
          storageRepository,
        ),
        _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _requestPermissionUseCase = RequestPermissionUseCase(
          permissionRepository,
        );

  void call(String destination) => _callUseCase.execute(
        Watcher(
          onComplete: callOnComplete,
          onError: (e) => callOnError(e),
        ),
        CallUseCaseParams(destination),
      );

  void checkCallPermission() => _getPermissionStatusUseCase.execute(
        Watcher(
          onNext: onCheckCallPermissionNext,
        ),
        GetPermissionStatusUseCaseParams(Permission.phone),
      );

  void askCallPermission() => _requestPermissionUseCase.execute(
        Watcher(
          onNext: onCheckCallPermissionNext,
        ),
        RequestPermissionUseCaseParams(Permission.phone),
      );

  void getLatestNumber() => _getLatestDialedNumberUseCase.execute(
        Watcher(
          onNext: onGetLatestDialedNumberNext,
        ),
      );

  void getSettings() => _getSettingsUseCase.execute(
        Watcher(
          onNext: onGetSettingsNext,
        ),
      );

  @override
  void dispose() {
    _callUseCase.dispose();
  }
}
