import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../resources/localizations.dart';

import 'controller.dart';

class WelcomePage extends View {
  final VoidCallback forward;

  WelcomePage(
    this.forward, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomePageState(forward);
}

class _WelcomePageState extends ViewState<WelcomePage, WelcomeController> {
  _WelcomePageState(VoidCallback forward) : super(WelcomeController(forward));

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
