import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/brand.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/logging.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';

import '../../../util/conditional_capitalization.dart';

import 'controller.dart';

class LoginPage extends View {
  final AuthRepository _authRepository;
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  final Brand _brand;
  final VoidCallback forward;

  LoginPage(
    this._authRepository,
    this._settingRepository,
    this._loggingRepository,
    this._brand,
    this.forward, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState(
        _authRepository,
        _settingRepository,
        _loggingRepository,
        _brand,
        forward,
      );
}

class _LoginPageState extends ViewState<LoginPage, LoginController>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  _LoginPageState(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    Brand brand,
    VoidCallback forward,
  ) : super(LoginController(authRepository, settingRepository,
            loggingRepository, brand, forward));

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
          AnimatedSize(
            curve: _curve,
            duration: _duration,
            vsync: this,
            child: AnimatedOpacity(
              curve: _curve,
              duration: _duration,
              opacity: controller.loginFailed ? 1 : 0,
              child: Visibility(
                visible: controller.loginFailed,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.brandTheme.errorBorderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.brandTheme.errorBorderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              VialerSans.exclamationMark,
                              color: context.brandTheme.errorContentColor,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                context.msg.onboarding.login.error
                                    .wrongCombination,
                                style: TextStyle(
                                  color: context.brandTheme.errorContentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
          Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: StylizedButton.raised(
                  onPressed: controller.canLogin ? controller.login : null,
                  child: Text(context.msg.onboarding.button.login
                      .toUpperCaseIfAndroid(context)),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: StylizedButton.outline(
                  onPressed: controller.goToPasswordReset,
                  child: Text(
                    context.msg.onboarding.login.button.forgotPassword
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
