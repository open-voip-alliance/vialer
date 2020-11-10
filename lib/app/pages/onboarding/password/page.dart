import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import '../widgets/error.dart';

import '../../../util/conditional_capitalization.dart';

import '../cubit.dart';
import 'cubit.dart';

class PasswordPage extends StatefulWidget {
  PasswordPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage>
    with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      _canSubmit = _passwordController.text != null &&
          _passwordController.text.isNotEmpty;
    });
  }

  void _onStateChanged(BuildContext context, PasswordState state) {
    if (state is PasswordChanged) {
      FocusScope.of(context).unfocus();
      context.read<OnboardingCubit>().forward();
    }
  }

  void _onChangePasswordButtonPressed(BuildContext context) {
    if (_canSubmit) {
      context.watch<PasswordCubit>().changePassword(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: Provider.of<EdgeInsets>(context).copyWith(top: 32),
        child: BlocProvider<PasswordCubit>(
          create: (_) => PasswordCubit(context.read<OnboardingCubit>()),
          child: BlocConsumer<PasswordCubit, PasswordState>(
            listener: _onStateChanged,
            builder: (context, state) {
              return Column(
                children: <Widget>[
                  Text(
                    context.msg.onboarding.password.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  ErrorAlert(
                    visible: state is PasswordNotAllowed,
                    child: Text(context.msg.onboarding.password.error),
                  ),
                  StylizedTextField(
                    controller: _passwordController,
                    prefixIcon: VialerSans.lockOn,
                    obscureText: true,
                    hasError: state is PasswordNotAllowed,
                  ),
                  SizedBox(height: 16),
                  Text(
                    context.msg.onboarding.password.requirements,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
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
