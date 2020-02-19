import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:provider/provider.dart';
import 'package:vialer_lite/data/repositories/auth_repository.dart';

import '../../../resources/theme.dart';
import '../widgets/stylized_button.dart';
import '../widgets/stylized_text_field.dart';
import 'controller.dart';

class LoginPage extends View {
  final VoidCallback forward;

  LoginPage(this.forward, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState(forward);
}

class _LoginPageState extends ViewState<LoginPage, LoginController>
    with WidgetsBindingObserver {


  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  _LoginPageState(VoidCallback forward)
      : super(LoginController(DataAuthRepository(), forward));



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
            height: controller.headerDistance,
          ),
          StylizedTextField(
            controller: controller.usernameController,
            prefixIcon: VialerSans.user,
            labelText: 'Username',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20),
          StylizedTextField(
            controller: controller.passwordController,
            prefixIcon: VialerSans.lockOn,
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
                    onPressed: controller.login,
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
    );
  }
}
