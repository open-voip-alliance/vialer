import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/entities/onboarding/step.dart';
import '../../../../domain/entities/need_to_change_password.dart';
import '../../../../domain/entities/brand.dart';

import '../../../../domain/repositories/auth.dart';

import '../../../../dependency_locator.dart';
import '../../../util/debug.dart';

import 'presenter.dart';

class LoginController extends Controller {
  // TODO: Repository used in controller?
  final _authRepository = dependencyLocator<AuthRepository>();

  final _brand = dependencyLocator<Brand>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final _presenter = LoginPresenter();

  final VoidCallback _forward;
  final void Function(Step) _addStep;

  EdgeInsets defaultPadding;
  EdgeInsets padding;

  double defaultHeaderDistance = 48;
  double headerDistance;

  bool canLogin = false;
  bool loggingIn = false;
  bool loginFailed = false;

  LoginController(this._forward, this._addStep);

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
    logger.info('Logging in');

    loggingIn = true;
    refreshUI();

    _presenter.login(usernameController.text.trim(), passwordController.text);
  }

  void _onLogin(bool success) {
    loggingIn = false;

    if (success) {
      logger.info('Login successful');
      doIfNotDebug(() async {
        await Segment.identify(
          userId: _authRepository.currentUser.uuid,
        );
        await Segment.track(eventName: 'login');
      });

      FocusScope.of(getContext()).unfocus();

      logger.info('Writing default settings');
      _presenter.resetSettingsToDefaults();

      _forward();
    } else {
      logger.info('Login failed');
      loginFailed = true;

      refreshUI();
    }
  }

  void _onLoginError(dynamic e) {
    if (e is NeedToChangePassword) {
      _addStep(Step.password);
      _forward();
    } else {
      throw e;
    }
  }

  void goToPasswordReset() {
    launch(_brand.baseUrl.resolve('/user/password_reset/').toString());
  }

  @override
  void initListeners() {
    _presenter.loginOnNext = _onLogin;
    _presenter.loginOnError = _onLoginError;
  }
}
