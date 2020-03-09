import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../util/debug.dart';

import 'presenter.dart';

class LoginController extends Controller {
  final AuthRepository _authRepository;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final LoginPresenter _presenter;

  final VoidCallback _forward;

  EdgeInsets defaultPadding;
  EdgeInsets padding;

  double defaultHeaderDistance = 48;
  double headerDistance;

  bool canLogin = false;

  LoginController(
    this._authRepository,
    SettingRepository settingRepository,
    this._forward,
  ) : _presenter = LoginPresenter(_authRepository, settingRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    void toggleLoginButton() {
      final isValidEmail = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(usernameController.text);

      final oldCanLogin = canLogin;
      if (isValidEmail && passwordController.text.isNotEmpty) {
        canLogin = true;
      } else {
        canLogin = false;
      }

      if (oldCanLogin != canLogin) {
        refreshUI();
      }
    }

    usernameController.addListener(toggleLoginButton);
    passwordController.addListener(toggleLoginButton);
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

  Future<void> _onLogin(bool success) async {
    if (success) {
      doIfNotDebug(() async {
        await Segment.identify(
          userId: (await _authRepository.currentUser).uuid,
        );
        await Segment.track(eventName: 'login');
      });

      FocusScope.of(getContext()).requestFocus(FocusNode());

      _presenter.resetSettingsToDefaults();

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
