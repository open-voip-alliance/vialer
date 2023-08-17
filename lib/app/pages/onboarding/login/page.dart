import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../domain/user/launch_privacy_policy.dart';
import '../../../../domain/user/launch_sign_up.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../../../widgets/connectivity_checker.dart';
import '../../../widgets/stylized_button.dart';
import '../cubit.dart';
import '../widgets/error.dart';
import '../widgets/stylized_text_field.dart';
import 'cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LoginPageState();

  static const keys = _Keys();
}

class _LoginPageState extends State<LoginPage>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        WidgetsBindingObserverRegistrar {
  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  void _goToPasswordReset() {
    unawaited(
      launchUrlString(
        context.brand.url.resolve('/user/password_reset/').toString(),
      ),
    );
  }

  void _toggleHidePassword() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  Future<void> _onStateChanged(BuildContext context, LoginState state) async {
    final onboarding = context.read<OnboardingCubit>();

    if (state is LoggedIn || state is LoginRequiresTwoFactorCode) {
      FocusScope.of(context).unfocus();
      onboarding.forward(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final defaultPadding = Provider.of<EdgeInsets>(context);

        return AnimatedContainer(
          curve: _curve,
          duration: _duration,
          padding: !isKeyboardVisible
              ? defaultPadding
              : defaultPadding.copyWith(top: 24),
          child: BlocProvider<LoginCubit>(
            create: (_) => LoginCubit(context.read<OnboardingCubit>()),
            child: BlocConsumer<LoginCubit, LoginState>(
              listener: _onStateChanged,
              builder: (context, loginState) {
                return AutofillGroup(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            context.msg.onboarding.login.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          curve: _curve,
                          duration: _duration,
                          height: isKeyboardVisible ? 16 : 48,
                        ),
                        BlocBuilder<ConnectivityCheckerCubit,
                            ConnectivityState>(
                          builder: (context, connectivityState) {
                            return ErrorAlert(
                              visible: loginState is LoginFailed ||
                                  connectivityState is Disconnected,
                              inline: false,
                              title: loginState is LoginFailed
                                  ? context.msg.onboarding.login.error
                                      .wrongCombination.title
                                  : context.msg.connectivity.noConnection.title,
                              message: loginState is LoginFailed
                                  ? context.msg.onboarding.login.error
                                      .wrongCombination.message
                                  : context
                                      .msg.connectivity.noConnection.message,
                            );
                          },
                        ),
                        StylizedTextField(
                          key: LoginPage.keys.emailField,
                          controller: _emailController,
                          autoCorrect: false,
                          prefixIcon: FontAwesomeIcons.user,
                          labelText:
                              context.msg.onboarding.login.placeholder.email,
                          keyboardType: TextInputType.emailAddress,
                          hasError: loginState is LoginFailed ||
                              (loginState is LoginNotSubmitted &&
                                  !loginState.hasValidEmailFormat),
                          autofillHints: const [AutofillHints.email],
                        ),
                        ErrorAlert(
                          key: LoginPage.keys.wrongEmailFormatError,
                          visible: loginState is LoginNotSubmitted &&
                              !loginState.hasValidEmailFormat,
                          inline: true,
                          message: context
                              .msg.onboarding.login.error.wrongEmailFormat,
                        ),
                        const SizedBox(height: 20),
                        StylizedTextField(
                          key: LoginPage.keys.passwordField,
                          controller: _passwordController,
                          prefixIcon: FontAwesomeIcons.lock,
                          suffix: IconButton(
                            key: LoginPage.keys.showPasswordButton,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.decelerate,
                              switchOutCurve: Curves.decelerate.flipped,
                              child: FaIcon(
                                _hidePassword
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye,
                                color: context.brand.theme.colors.primary,
                                size: 20,
                                key: ValueKey(_hidePassword),
                              ),
                            ),
                            onPressed: _toggleHidePassword,
                          ),
                          labelText:
                              context.msg.onboarding.login.placeholder.password,
                          obscureText: _hidePassword,
                          hasError: loginState is LoginFailed ||
                              (loginState is LoginNotSubmitted &&
                                  !loginState.hasValidPasswordFormat),
                          autofillHints: const [AutofillHints.password],
                        ),
                        ErrorAlert(
                          key: LoginPage.keys.wrongPasswordFormatError,
                          visible: loginState is LoginNotSubmitted &&
                              !loginState.hasValidPasswordFormat,
                          inline: true,
                          message: context
                              .msg.onboarding.login.error.wrongPasswordFormat,
                        ),
                        const SizedBox(height: 32),
                        Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: BlocBuilder<ConnectivityCheckerCubit,
                                  ConnectivityState>(
                                builder: (context, connectivityState) {
                                  return StylizedButton.raised(
                                    key: LoginPage.keys.loginButton,
                                    onPressed: loginState is! LoggingIn &&
                                            connectivityState is! Disconnected
                                        ? () => unawaited(
                                              context.read<LoginCubit>().login(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                  ),
                                            )
                                        : null,
                                    child: AnimatedSwitcher(
                                      switchInCurve: Curves.decelerate,
                                      switchOutCurve: Curves.decelerate.flipped,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: loginState is! LoggingIn
                                          ? Text(
                                              context
                                                  .msg.onboarding.button.login
                                                  .toUpperCaseIfAndroid(
                                                context,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    context.msg.onboarding.login
                                                        .button.loggingIn
                                                        .toUpperCaseIfAndroid(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: StylizedButton.outline(
                                onPressed: _goToPasswordReset,
                                child: Text(
                                  context.msg.onboarding.login.button
                                      .forgotPassword
                                      .toUpperCaseIfAndroid(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (context.read<LoginCubit>().shouldShowSignUpLink)
                              TextButton(
                                onPressed: () => LaunchSignUp()(),
                                child: Text(
                                  context.msg.onboarding.login.button
                                      .signUp(context.brand.appName)
                                      .toUpperCaseIfAndroid(context),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            TextButton(
                              onPressed: () => LaunchPrivacyPolicy()(),
                              child: Text(
                                context.msg.main.settings.privacyPolicy
                                    .toUpperCaseIfAndroid(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Keys {
  const _Keys();

  Key get loginButton => const Key('loginButton');

  Key get emailField => const Key('emailField');

  Key get passwordField => const Key('passwordField');

  Key get showPasswordButton => const Key('showPasswordButton');

  Key get wrongEmailFormatError => const Key('wrongEmailFormatError');

  Key get wrongPasswordFormatError => const Key('wrongPasswordFormatError');
}
