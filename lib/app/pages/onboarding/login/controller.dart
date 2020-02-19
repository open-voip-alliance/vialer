import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth_repository.dart';

import 'presenter.dart';

class LoginController extends Controller {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final LoginPresenter _presenter;

  final VoidCallback _forward;

  EdgeInsets defaultPadding;
  EdgeInsets padding;

  double defaultHeaderDistance = 48;
  double headerDistance;

  LoginController(AuthRepository authRepository, this._forward)
      : _presenter = LoginPresenter(authRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // If there's a bottom view inset, there's most likely a keyboard
    // displaying.
    if (WidgetsBinding.instance.window.viewInsets.bottom > 0) {
      padding = defaultPadding.copyWith(
        top: 24,
      );

      headerDistance = 24;
    } else {
      padding = defaultPadding;
      headerDistance = defaultHeaderDistance;
    }

    refreshUI();
  }

  void login() {
    _presenter.login(usernameController.text, passwordController.text);
  }

  void _onLogin(bool success) {
    if (success) {
      _forward();
    } else {
      print('login failed');
    }

    // TODO: Show error on fail
  }

  @override
  void initListeners() {
    _presenter.loginOnNext = _onLogin;
  }
}
