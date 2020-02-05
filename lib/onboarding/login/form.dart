import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vialer_lite/auth/bloc.dart';

import '../../api/api.dart';
import '../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import 'bloc.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback forward;

  LoginForm._(this.forward);

  static Widget create({@required VoidCallback forward}) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(
        api: context.api,
        authBloc: context.bloc<AuthBloc>(),
      ),
      child: LoginForm._(forward),
    );
  }

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with WidgetsBindingObserver {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  EdgeInsets _defaultPadding;
  EdgeInsets _padding;

  double _defaultHeaderDistance = 48;
  double _headerDistance;

  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // If there's a bottom view inset, there's most likely a keyboard
    // displaying.
    if (WidgetsBinding.instance.window.viewInsets.bottom > 0) {
      setState(() {
        _padding = _defaultPadding.copyWith(
          top: 24,
        );

        _headerDistance = 24;
      });
    } else {
      setState(() {
        _padding = _defaultPadding;
        _headerDistance = _defaultHeaderDistance;
      });
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
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessful) {
          widget.forward();
        }
      },
      child: AnimatedContainer(
        curve: _curve,
        duration: _duration,
        padding: _padding,
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
            AnimatedContainer(
              curve: _curve,
              duration: _duration,
              height: _headerDistance,
            ),
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
            Padding(
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
                ],
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
