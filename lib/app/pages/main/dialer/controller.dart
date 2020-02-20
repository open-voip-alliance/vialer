import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';

import 'confirm/page.dart';
import 'presenter.dart';

class DialerController extends Controller {
  final DialerPresenter _presenter;

  final keypadController = TextEditingController();

  DialerController(CallRepository callRepository)
      : _presenter = DialerPresenter(callRepository);

  void call() {
    Navigator.push(
      getContext(),
      ConfirmPageRoute(destination: keypadController.text),
    );
  }

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
  }
}
