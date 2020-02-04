import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer_lite/auth/bloc.dart';

import '../../api/api.dart';
import '../../routes.dart';
import '../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import 'bloc.dart';

class LoginForm extends StatefulWidget {
  LoginForm._();

  static Widget create() {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(
        api: context.api,
        authBloc: context.bloc<AuthBloc>(),
      ),
      child: LoginForm._(),
    );
  }

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessful) {
          Navigator.pushNamed(context, Routes.dialer);
        }
      },
      child: Column(
        children: <Widget>[
          Text(
            'Log in',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 48),
          StylizedTextField(
            controller: _usernameController,
            prefixIcon: Icons.person,
            labelText: 'Username',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20),
          StylizedTextField(
            controller: _passwordController,
            prefixIcon: Icons.lock,
            labelText: 'Password',
            obscureText: true,
          ),
          SizedBox(height: 32),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: StylizedRaisedButton(
                      text: 'Log in',
                      onPressed: () => context.bloc<LoginBloc>().add(
                            Login(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            ),
                          ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: StylizedOutlineButton(
                      text: 'Forgot password',
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: StylizedFlatButton(
                          text: 'Create account',
                          onPressed: () {},
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
