import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/call.dart';
import '../../../../domain/usecases/get_latest_dialed_number.dart';
import '../../../../domain/usecases/onboarding/request_permission.dart';

import '../../../../domain/entities/permission.dart';

import '../../../../domain/usecases/get_permission_status.dart';

import '../../../../domain/usecases/get_settings.dart';

class DialerPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function onCheckCallPermissionNext;

  Function onGetLatestDialedNumberNext;

  Function onGetSettingsNext;

  final _call = CallUseCase();
  final _getLatestDialedNumber = GetLatestDialedNumber();
  final _getSettings = GetSettingsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();

  void call(String destination) => _call(destination: destination).then(
        callOnComplete,
        onError: callOnError,
      );

  void checkCallPermission() => _getPermissionStatus(
        permission: Permission.phone,
      ).then(onCheckCallPermissionNext);

  void askCallPermission() => _requestPermission(permission: Permission.phone)
      .then(onCheckCallPermissionNext);

  void getLatestNumber() =>
      onGetLatestDialedNumberNext(_getLatestDialedNumber());

  void getSettings() => _getSettings().then(onGetSettingsNext);

  @override
  void dispose() {}
}
