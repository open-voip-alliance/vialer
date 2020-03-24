import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';

import '../../../../domain/entities/permission_status.dart';
import '../../../../domain/repositories/permission.dart';

import 'caller.dart';
import 'presenter.dart';

class DialerController extends Controller with Caller {
  final DialerPresenter _presenter;

  final String initialDestination;

  final keypadController = TextEditingController();

  bool _canCall = true;

  bool get canCall => _canCall;

  DialerController(
    CallRepository callRepository,
    PermissionRepository permissionRepository,
    this.initialDestination,
  ) : _presenter = DialerPresenter(callRepository, permissionRepository);

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
  }

  void startCall() => call(keypadController.text);

  @override
  void executeCall(String destination) => _presenter.call(destination);

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

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
    _presenter.onCheckCallPermissionNext = _onCheckCallPermissionNext;
  }
}
