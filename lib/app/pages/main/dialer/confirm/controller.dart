import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:vialer_lite/app/pages/main/dialer/confirm/page.dart';

import '../../../../../domain/repositories/call_repository.dart';

import 'presenter.dart';

class ConfirmController extends Controller {
  final DialerPresenter _presenter;

  final String destination;

  bool _showedDialog = false;
  bool _madeCall = false;

  AnimationController _animationController;

  ConfirmController(CallRepository callRepository, this.destination)
      : _presenter = DialerPresenter(callRepository);

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
        Navigator.of(getContext()).pop();
      }
    });

    controller.forward();
  }

  void call() {
    _presenter.call(destination);
  }

  void pop() {
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

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
  }
}
