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
    final destination = keypadController.text;
    logger.info('Start calling: $destination, going to call through page');
    Navigator.push(
      getContext(),
      ConfirmPageRoute(destination: destination),
    );
  }

  @override
  void initListeners() {
    _presenter.callOnComplete = () {};
  }
}
