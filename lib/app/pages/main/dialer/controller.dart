import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/permission_status.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/permission.dart';
import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import 'caller.dart';
import 'presenter.dart';

class DialerController extends Controller with Caller {
  @override
  final CallRepository callRepository;

  @override
  final SettingRepository settingRepository;

  @override
  final LoggingRepository loggingRepository;

  final DialerPresenter _presenter;

  final String initialDestination;

  final keypadController = TextEditingController();

  bool _canCall = true;

  bool get canCall => _canCall;

  bool _showSettingsDirections = false;

  bool get showSettingsDirections => _showSettingsDirections;

  String _latestDialedNumber;

  DialerController(
    this.callRepository,
    this.settingRepository,
    this.loggingRepository,
    PermissionRepository permissionRepository,
    StorageRepository storageRepository,
    this.initialDestination,
  ) : _presenter = DialerPresenter(
          callRepository,
          permissionRepository,
          storageRepository,
          settingRepository,
        );

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    executeGetSettingsUseCase();

    if (initialDestination != null) {
      keypadController.text = initialDestination;
    }

    if (!Platform.isIOS) {
      logger.info('Checking call permission');
      _presenter.checkCallPermission();
    }

    _presenter.getLatestNumber();
  }

  void askPermission() => _presenter.askCallPermission();

  void startCall() {
    final currentNumber = keypadController.text;

    if (currentNumber == null || currentNumber.isEmpty) {
      if (_latestDialedNumber == null) {
        return;
      }

      keypadController.text = _latestDialedNumber;
      return;
    }

    call(currentNumber);
    keypadController.text = '';
  }

  @override
  void executeCallUseCase(String destination) {
    _presenter.call(destination);
  }

  void _onCallInitiated() {
    // Pop the dialer away during a call.
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.of(getContext()).pop();
    });
  }

  void _onCheckCallPermissionNext(PermissionStatus status) {
    _showSettingsDirections = status == PermissionStatus.permanentlyDenied;
    _canCall = status == PermissionStatus.granted;

    if (_canCall && initialDestination != null) {
      call(initialDestination);
    } else {
      refreshUI();
    }
  }

  // ignore: use_setters_to_change_properties
  void _onGetLatestDialedNumber(String number) {
    _latestDialedNumber = number;
  }

  @override
  void executeGetSettingsUseCase() => _presenter.getSettings();

  @override
  void initListeners() {
    _presenter.callOnComplete = _onCallInitiated;
    _presenter.callOnError = showException;
    _presenter.onCheckCallPermissionNext = _onCheckCallPermissionNext;
    _presenter.onGetLatestDialedNumberNext = _onGetLatestDialedNumber;
    _presenter.onGetSettingsNext = setSettings;
  }
}
