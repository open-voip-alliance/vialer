import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/auth.dart';

import '../../../resources/localizations.dart';

import 'controller.dart';

class WelcomePage extends View {
  final VoidCallback forward;
  final AuthRepository _authRepository;

  WelcomePage(
    this._authRepository,
    this.forward, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _WelcomePageState(_authRepository, forward);
}

class _WelcomePageState extends ViewState<WelcomePage, WelcomeController> {
  _WelcomePageState(AuthRepository authRepository, VoidCallback forward)
      : super(WelcomeController(authRepository, forward));

  @override
  Widget buildPage() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '${context.msg.onboarding.welcome.title}\n',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: controller.systemUser?.firstName ?? '',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
