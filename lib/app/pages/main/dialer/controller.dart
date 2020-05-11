import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/repositories/storage.dart';

import '../../../../domain/entities/permission_status.dart';
import '../../../../domain/repositories/permission.dart';

import 'caller.dart';
import 'presenter.dart';

class DialerController extends Controller with Caller {
  @override
  final CallRepository callRepository;

  final DialerPresenter _presenter;

  final String initialDestination;

  final keypadController = TextEditingController();

  bool _canCall = true;

  bool get canCall => _canCall;

  String _latestDialedNumber;

  DialerController(
    this.callRepository,
    PermissionRepository permissionRepository,
    StorageRepository storageRepository,
    this.initialDestination,
  ) : _presenter = DialerPresenter(
          callRepository,
          permissionRepository,
          storageRepository,
        );

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    if (initialDestination != null) {
      keypadController.text = initialDestination;
    }

    if (!Platform.isIOS) {
      logger.info('Checking call permission');
      _presenter.checkCallPermission();
    }

    _presenter.getLatestNumber();
  }

  void startCall() {
    var numberToCall = keypadController.text;

    if (numberToCall == null || numberToCall.isEmpty) {
      if (_latestDialedNumber == null) {
        return;
      }

      numberToCall = _latestDialedNumber;
    }

    call(numberToCall);
    _latestDialedNumber = numberToCall;
  }

  @override
  void executeCallUseCase(String destination) => _presenter.call(destination);

  void _onCheckCallPermissionNext(PermissionStatus status) {
    logger.info('Call permission is: $status');
    if (status != PermissionStatus.granted) {
      _canCall = false;
      refreshUI();
    }

    if (_canCall && initialDestination != null) {
      call(initialDestination);
    }
  }

  // ignore: use_setters_to_change_properties
  void _onGetLatestDialedNumber(String number) {
    _latestDialedNumber = number;
  }

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
    _presenter.onCheckCallPermissionNext = _onCheckCallPermissionNext;
    _presenter.callOnError = showException;
    _presenter.onGetLatestDialedNumberNext = _onGetLatestDialedNumber;
  }
}
