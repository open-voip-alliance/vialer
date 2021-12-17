import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
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

  EdgeInsets? _defaultPadding;
  EdgeInsets? _padding;

  final _defaultHeaderDistance = 48.0;
  double? _headerDistance;

  bool _hidePassword = true;

  void _goToPasswordReset() {
    launch(
      context.brand.url.resolve('/user/password_reset/').toString(),
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    _defaultPadding = Provider.of<EdgeInsets>(context);

    if (_padding == null) {
      _padding = _defaultPadding;
    }

    if (_headerDistance == null) {
      _headerDistance = _defaultHeaderDistance;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    setState(() {
      // If there's a bottom view inset, there's most likely a keyboard
      // displaying.
      if (WidgetsBinding.instance!.window.viewInsets.bottom > 0) {
        _padding = _defaultPadding!.copyWith(
          top: 24,
        );

        _headerDistance = 24;
      } else {
        _padding = _defaultPadding;
        _headerDistance = _defaultHeaderDistance;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AnimatedContainer(
      curve: _curve,
      duration: _duration,
      padding: !isLandscape ? _padding : _padding!.copyWith(top: 24),
      child: BlocProvider<LoginCubit>(
        create: (_) => LoginCubit(context.read<OnboardingCubit>()),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: _onStateChanged,
          builder: (context, loginState) {
            return AutofillGroup(
              child: Column(
                children: <Widget>[
                  if (!isLandscape) ...[
                    Text(
                      context.msg.onboarding.login.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    AnimatedContainer(
                      curve: _curve,
                      duration: _duration,
                      height: _headerDistance,
                    ),
                  ],
                  BlocBuilder<ConnectivityCheckerCubit, ConnectivityState>(
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
                            : context.msg.connectivity.noConnection.message,
                      );
                    },
                  ),
                  StylizedTextField(
                    controller: _emailController,
                    autoCorrect: false,
                    textCapitalization: TextCapitalization.none,
                    prefixIcon: VialerSans.user,
                    labelText: context.msg.onboarding.login.placeholder.email,
                    keyboardType: TextInputType.emailAddress,
                    hasError: loginState is LoginFailed ||
                        (loginState is LoginNotSubmitted &&
                            !loginState.hasValidEmailFormat),
                    autofillHints: [AutofillHints.email],
                  ),
                  ErrorAlert(
                    visible: (loginState is LoginNotSubmitted &&
                        !loginState.hasValidEmailFormat),
                    inline: true,
                    message:
                        context.msg.onboarding.login.error.wrongEmailFormat,
                  ),
                  const SizedBox(height: 20),
                  StylizedTextField(
                    controller: _passwordController,
                    prefixIcon: VialerSans.lockOn,
                    suffix: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.decelerate,
                        switchOutCurve: Curves.decelerate.flipped,
                        child: Icon(
                          _hidePassword ? VialerSans.eyeOff : VialerSans.eye,
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
                    autofillHints: [AutofillHints.password],
                  ),
                  ErrorAlert(
                    visible: (loginState is LoginNotSubmitted &&
                        !loginState.hasValidPasswordFormat),
                    inline: true,
                    message:
                        context.msg.onboarding.login.error.wrongPasswordFormat,
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
                              onPressed: loginState is! LoggingIn &&
                                      connectivityState is! Disconnected
                                  ? () => context.read<LoginCubit>().login(
                                        _emailController.text,
                                        _passwordController.text,
                                      )
                                  : null,
                              child: AnimatedSwitcher(
                                switchInCurve: Curves.decelerate,
                                switchOutCurve: Curves.decelerate.flipped,
                                duration: const Duration(milliseconds: 200),
                                child: loginState is! LoggingIn
                                    ? Text(
                                        context.msg.onboarding.button.login
                                            .toUpperCaseIfAndroid(context),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              context.msg.onboarding.login
                                                  .button.loggingIn
                                                  .toUpperCaseIfAndroid(
                                                      context),
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
          },
        ),
      ),
    );
  }
}
