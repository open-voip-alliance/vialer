import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import 'presenter.dart';

class PasswordController extends Controller {
  final passwordController = TextEditingController();

  final PasswordPresenter _presenter;

  final VoidCallback _forward;

  bool canSubmit = false;

  bool loginFailed = false;

  PasswordController(
    AuthRepository _authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    this._forward,
  ) : _presenter = PasswordPresenter(
          _authRepository,
          settingRepository,
          loggingRepository,
        );

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
    _presenter.changePassword(passwordController.text);
  }

  void _onChangePassword() {
    FocusScope.of(getContext()).unfocus();
    _forward();
  }

  void _onChangePasswordError(dynamic e) => throw e;

  @override
  void initListeners() {
    _presenter.changePaswordOnComplete = _onChangePassword;
    _presenter.changePasswordOnError = _onChangePasswordError;
  }
}
