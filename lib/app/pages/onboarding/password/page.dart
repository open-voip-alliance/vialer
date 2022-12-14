import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../resources/localizations.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../util/password.dart';
import '../../../widgets/stylized_button.dart';
import '../cubit.dart';
import '../widgets/error.dart';
import '../widgets/stylized_text_field.dart';
import 'cubit.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage>
    with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  bool _canSubmit = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      _canSubmit = hasValidPasswordFormat(_passwordController.text);
    });
  }

  void _onStateChanged(BuildContext context, PasswordState state) {
    if (state is PasswordChanged) {
      FocusScope.of(context).unfocus();
      context.read<OnboardingCubit>().forward(
            password: _passwordController.text,
          );
    }
  }

  void _onChangePasswordButtonPressed(BuildContext context) {
    if (_canSubmit) {
      context.read<PasswordCubit>().changePassword(_passwordController.text);
    }
  }

  void _toggleHidePassword() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: Provider.of<EdgeInsets>(context).copyWith(top: 32),
        child: BlocProvider<PasswordCubit>(
          create: (context) => PasswordCubit(context.read<OnboardingCubit>()),
          child: BlocConsumer<PasswordCubit, PasswordState>(
            listener: _onStateChanged,
            builder: (context, state) {
              return Column(
                children: <Widget>[
                  Text(
                    context.msg.onboarding.password.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ErrorAlert(
                    visible: state is PasswordNotAllowed,
                    inline: false,
                    title: context.msg.onboarding.password.error.title,
                    message: context.msg.onboarding.password.error.message,
                  ),
                  StylizedTextField(
                    controller: _passwordController,
                    prefixIcon: FontAwesomeIcons.lock,
                    obscureText: _hidePassword,
                    hasError: state is PasswordNotAllowed,
                    suffix: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.decelerate,
                      switchOutCurve: Curves.decelerate.flipped,
                      child: IconButton(
                        key: ValueKey(_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                        ),
                        onPressed: _toggleHidePassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.msg.onboarding.password.requirements,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: StylizedButton.raised(
                      onPressed: () => _onChangePasswordButtonPressed(context),
                      child: Text(
                        context.msg.onboarding.password.button
                            .toUpperCaseIfAndroid(context),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}
