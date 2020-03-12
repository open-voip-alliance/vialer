import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/auth.dart';

import '../../../resources/theme.dart';
import '../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import 'controller.dart';

import '../../../resources/localizations.dart';

class LoginPage extends View {
  final AuthRepository _authRepository;
  final SettingRepository _settingRepository;
  final VoidCallback forward;

  LoginPage(
    this._authRepository,
    this._settingRepository,
    this.forward, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _LoginPageState(_authRepository, _settingRepository, forward);
}

class _LoginPageState extends ViewState<LoginPage, LoginController> {
  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  _LoginPageState(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    VoidCallback forward,
  ) : super(LoginController(authRepository, settingRepository, forward));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.defaultPadding = Provider.of<EdgeInsets>(context);

    if (controller.padding == null) {
      controller.padding = controller.defaultPadding;
    }

    if (controller.headerDistance == null) {
      controller.headerDistance = controller.defaultHeaderDistance;
    }
  }

  @override
  Widget buildPage() {
    return AnimatedContainer(
      key: globalKey,
      curve: _curve,
      duration: _duration,
      padding: controller.padding,
      child: Column(
        children: <Widget>[
          Text(
            context.msg.onboarding.login.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          AnimatedContainer(
            curve: _curve,
            duration: _duration,
            height: controller.headerDistance,
          ),
          StylizedTextField(
            controller: controller.usernameController,
            prefixIcon: VialerSans.user,
            labelText: context.msg.onboarding.login.placeholder.username,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20),
          StylizedTextField(
            controller: controller.passwordController,
            prefixIcon: VialerSans.lockOn,
            labelText: context.msg.onboarding.login.placeholder.password,
            obscureText: true,
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: StylizedRaisedButton(
                    text: context.msg.onboarding.button.login,
                    onPressed: controller.canLogin ? controller.login : null,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: StylizedOutlineButton(
                    text: context.msg.onboarding.login.button.forgotPassword,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
