import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/caller.dart';

import '../../../../domain/entities/permission_status.dart';

import 'presenter.dart';

class DialerController extends Controller {
  final _presenter = DialerPresenter();

  final String initialDestination;

  final keypadController = TextEditingController();

  bool _canCall = true;

  bool get canCall => _canCall;

  bool _showSettingsDirections = false;

  bool get showSettingsDirections => _showSettingsDirections;

  String _latestDialedNumber;

  DialerController(this.initialDestination);

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

    getContext().bloc<CallerCubit>().call(currentNumber);
    keypadController.text = '';
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
      getContext().bloc<CallerCubit>().call(initialDestination);
    } else {
      refreshUI();
    }
  }

  // ignore: use_setters_to_change_properties
  void _onGetLatestDialedNumber(String number) {
    _latestDialedNumber = number;
  }

  @override
  void initListeners() {
    _presenter.callOnComplete = _onCallInitiated;
    _presenter.onCheckCallPermissionNext = _onCheckCallPermissionNext;
    _presenter.onGetLatestDialedNumberNext = _onGetLatestDialedNumber;
  }
}
