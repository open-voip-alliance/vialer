import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import 'presenter.dart';

class PasswordController extends Controller {
  final passwordController = TextEditingController();

  final _presenter = PasswordPresenter();

  final VoidCallback _forward;

  bool canSubmit = false;

  bool passwordChangeFailed = false;

  PasswordController(this._forward);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    passwordController.addListener(() {
      canSubmit =
          passwordController.text != null && passwordController.text.isNotEmpty;
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    refreshUI();
  }

  void changePassword() {
    logger.info('Changing password');

    final password = passwordController.text;

    if (password.length < 6 || !RegExp(r'[^A-z]').hasMatch(password)) {
      _onChangePasswordError();
      return;
    }

    _presenter.changePassword(password);
  }

  void _onChangePassword() {
    FocusScope.of(getContext()).unfocus();
    _forward();
  }

  void _onChangePasswordError([_]) {
    passwordChangeFailed = true;
    refreshUI();
  }

  @override
  void initListeners() {
    _presenter.changePaswordOnComplete = _onChangePassword;
    _presenter.changePasswordOnError = _onChangePasswordError;
  }
}
