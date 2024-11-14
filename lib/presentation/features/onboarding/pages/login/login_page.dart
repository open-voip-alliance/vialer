import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../domain/usecases/user/launch_privacy_policy.dart';
import '../../../../../../domain/usecases/user/launch_sign_up.dart';
import '../../../../shared/controllers/connectivity_checker/cubit.dart';
import '../../../../shared/widgets/error.dart';
import '../../../../shared/widgets/stylized_button.dart';
import '../../../../shared/widgets/stylized_text_field.dart';
import '../../../../util/stylized_snack_bar.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../controllers/cubit.dart';
import '../../controllers/login/cubit.dart';
import '../password_forgotten/password_forgotten_page.dart';

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

  /// Navigates to the password forgotten page.
  ///
  /// This method is used to navigate to the [PasswordForgottenPage] and pass the email
  /// entered in the login page to the [PasswordForgottenPage] using the [emailController].
  /// It returns a [String] message after navigating back from the [PasswordForgottenPage].
  /// The [message] can be null if no message is returned.
  void _goToPasswordForgotten() async {
    final message = await Navigator.push<String?>(
      context,
      platformPageRoute(
        fullscreenDialog: true,
        context: context,
        builder: (context) => PasswordForgottenPage(
          emailController: TextEditingController(
            text: _emailController.text,
          ),
        ),
      ),
    );

    // Delay the snackbar to prevent it from showing before the page transition
    Future.delayed(const Duration(milliseconds: 500), () {
      if (message != null) {
        _showSnackBarResetPassword(content: message);
      }
    });
  }

  /// Shows a snackbar with a reset password message.
  ///
  /// The [content] parameter is the message to be displayed in the snackbar.
  void _showSnackBarResetPassword({required String content}) {
    showSnackBar(
      context,
      duration: const Duration(seconds: 5),
      icon: const FaIcon(FontAwesomeIcons.check),
      label: Text(content),
      padding: const EdgeInsets.only(right: 72),
    );
  }

  void _toggleHidePassword() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  Future<void> _onStateChanged(BuildContext context, LoginState state) async {
    final onboarding = context.read<OnboardingCubit>();

    if (state is LoggedIn ||
        state is LoginRequiresTwoFactorCode ||
        state is LoggedInAndNeedToChangePassword) {
      FocusScope.of(context).unfocus();
      onboarding.forward(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  void _login(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    unawaited(
      cubit.login(_emailController.text, _passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final defaultPadding =
            Provider.of<EdgeInsets>(context).copyWith(top: 60);

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
                              fontSize: 40,
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
                                color: context.brand.theme.colors.infoText,
                                size: 16,
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
                                    colored: true,
                                    key: LoginPage.keys.loginButton,
                                    onPressed: loginState is! LoggingIn &&
                                            connectivityState is! Disconnected
                                        ? () => _login(context)
                                        : () => {},
                                    isLoading: loginState is LoggingIn,
                                    child: loginState is! LoggingIn
                                        ? PlatformText(
                                            context.msg.onboarding.button.login,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        : PlatformText(
                                            context.msg.onboarding.login.button
                                                .loggingIn,
                                            style: TextStyle(
                                              color: Colors.white,
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
                                colored: true,
                                onPressed: _goToPasswordForgotten,
                                child: PlatformText(
                                  context.msg.onboarding.login.button
                                      .forgotPassword,
                                  style: TextStyle(
                                    color: context.brand.theme.colors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (context.read<LoginCubit>().shouldShowSignUpLink)
                              TextButton(
                                onPressed: () => LaunchSignUp()(),
                                child: PlatformText(
                                  context.msg.onboarding.login.button
                                      .signUp(context.brand.appName),
                                  style: TextStyle(
                                    color: context.brand.theme.colors
                                        .userAvailabilityOffline,
                                  ),
                                ),
                              ),
                            TextButton(
                              onPressed: () => LaunchPrivacyPolicy()(),
                              child: PlatformText(
                                context.msg.main.settings.privacyPolicy,
                                style: TextStyle(
                                  color: context.brand.theme.colors
                                      .userAvailabilityOffline,
                                ),
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
