import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/repositories/logging.dart';
import '../../../../../domain/repositories/setting.dart';

import '../../../../../domain/repositories/call.dart';

import '../../../../routes.dart';
import 'presenter.dart';
import 'page.dart';

class ConfirmController extends Controller {
  final DialerPresenter _presenter;

  final String destination;

  bool _showedDialog = false;
  bool _madeCall = false;

  AnimationController _animationController;

  bool showConfirmPage = true;

  ConfirmController(
      CallRepository callRepository,
      SettingRepository settingRepository,
      LoggingRepository loggingRepository,
      this.destination)
      : _presenter = DialerPresenter(
            callRepository, settingRepository, loggingRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);
  }

  void initAnimation(AnimationController controller) {
    _animationController = controller;

    controller.addListener(() {
      if (controller.isCompleted && Platform.isIOS && !_madeCall) {
        call();
      } else if (controller.isDismissed) {
        if (Platform.isIOS) {
          Navigator.pop(getContext());
        } else {
          Navigator.popUntil(
            getContext(),
            (route) =>
                route.settings.name != Routes.dialer &&
                route is! ConfirmPageRoute,
          );
        }
      }
    });

    controller.forward();
  }

  void call() {
    logger.info('Initiating call to $destination');
    _presenter.call(destination);
  }

  void pop() {
    logger.info('Popping call through page');
    _animationController.reverse();
  }

  Future<bool> onWillPop() async {
    pop();
    // Return false because the popping will happen when the animation
    // is finished
    return false;
  }

  @override
  void onInActive() {
    super.onInActive();

    if (Platform.isIOS && !_showedDialog) {
      _showedDialog = true;
    } else {
      _madeCall = true;
    }

    if (Platform.isIOS &&
        _madeCall &&
        _animationController.status == AnimationStatus.reverse) {
      // Cancel the reverse animation when a call is going to be made
      _animationController.value = 1.0;
    }
  }

  @override
  void onResumed() {
    super.onResumed();

    _animationController.reverse();
  }

  // ignore: avoid_positional_boolean_parameters
  void setShowDialogSetting(bool value) {
    showConfirmPage = value;
    refreshUI();
    _presenter.setShowDialogSetting(value);
  }

  void _onSettingsNext(List<Setting> settings) {
    showConfirmPage = settings.get<ShowDialerConfirmPopupSetting>().value;
  }

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
    _presenter.settingsOnNext = _onSettingsNext;
  }
}
