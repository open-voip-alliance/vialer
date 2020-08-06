import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/onboarding/step.dart';
import '../../../../domain/entities/brand.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/logging.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import '../widgets/error.dart';

import '../../../util/conditional_capitalization.dart';

import 'controller.dart';

class LoginPage extends View {
  final AuthRepository _authRepository;
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  final Brand _brand;
  final VoidCallback forward;
  final void Function(Step) addStep;

  LoginPage(
    this._authRepository,
    this._settingRepository,
    this._loggingRepository,
    this._brand,
    this.forward,
    this.addStep, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState(
        _authRepository,
        _settingRepository,
        _loggingRepository,
        _brand,
        forward,
        addStep,
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
    void Function(Step) addStep,
  ) : super(
          LoginController(
            authRepository,
            settingRepository,
            loggingRepository,
            brand,
            forward,
            addStep,
          ),
        );

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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AnimatedContainer(
      key: globalKey,
      curve: _curve,
      duration: _duration,
      padding: !isLandscape
          ? controller.padding
          : controller.padding.copyWith(
              top: 24,
            ),
      child: Column(
        children: <Widget>[
          if (!isLandscape) ...[
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
          ],
          ErrorAlert(
            visible: controller.loginFailed,
            child: Text(
              context.msg.onboarding.login.error.wrongCombination,
            ),
          ),
          StylizedTextField(
            controller: controller.usernameController,
            autoCorrect: false,
            textCapitalization: TextCapitalization.none,
            prefixIcon: VialerSans.user,
            labelText: context.msg.onboarding.login.placeholder.username,
            keyboardType: TextInputType.emailAddress,
            hasError: controller.loginFailed,
          ),
          SizedBox(height: 20),
          StylizedTextField(
            controller: controller.passwordController,
            prefixIcon: VialerSans.lockOn,
            labelText: context.msg.onboarding.login.placeholder.password,
            obscureText: true,
            hasError: controller.loginFailed,
          ),
          SizedBox(height: 32),
          Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: StylizedButton.raised(
                  onPressed: controller.canLogin && !controller.loggingIn
                      ? controller.login
                      : null,
                  child: AnimatedSwitcher(
                    switchInCurve: Curves.decelerate,
                    switchOutCurve: Curves.decelerate.flipped,
                    duration: Duration(milliseconds: 200),
                    child: !controller.loggingIn
                        ? Text(
                            context.msg.onboarding.button.login
                                .toUpperCaseIfAndroid(context),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  context.msg.onboarding.login.button.loggingIn
                                      .toUpperCaseIfAndroid(context),
                                ),
                              ),
                            ],
                          ),
                  ),
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
