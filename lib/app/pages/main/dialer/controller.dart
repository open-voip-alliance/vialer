import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';

import '../../../../domain/entities/onboarding/permission_status.dart';
import '../../../../domain/repositories/permission.dart';

import 'confirm/page.dart';
import 'presenter.dart';

class DialerController extends Controller {
  final DialerPresenter _presenter;

  final keypadController = TextEditingController();

  bool _canCall = true;

  bool get canCall => _canCall;

  DialerController(
    CallRepository callRepository,
    PermissionRepository permissionRepository,
  ) : _presenter = DialerPresenter(callRepository, permissionRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    if (!Platform.isIOS) {
      logger.info('Checking call permission');
      _presenter.checkCallPermission();
    }
  }

  void call() {
    final destination = keypadController.text;
    logger.info('Start calling: $destination, going to call through page');
    Navigator.push(
      getContext(),
      ConfirmPageRoute(destination: destination),
    );
  }

  void _onCheckCallPermissionNext(PermissionStatus status) {
    logger.info('Call permission is: $status');
    if (status != PermissionStatus.granted) {
      _canCall = false;
      refreshUI();
    }
  }

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
    _presenter.onCheckCallPermissionNext = _onCheckCallPermissionNext;
  }
}
