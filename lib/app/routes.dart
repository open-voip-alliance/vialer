import 'package:flutter/material.dart';

import 'pages/main/dialer/page.dart';
import 'pages/main/page.dart';
import 'pages/main/settings/feedback/page.dart';
import 'pages/onboarding/page.dart';
import 'pages/splash/page.dart';

abstract class Routes {
  static const root = '/';
  static const onboarding = '/onboarding';

  static const main = '/main';

  static const dialer = '/dialer';

  static const feedback = '/feedback';

  static final mapped = <String, WidgetBuilder>{
    Routes.root: (_) => const SplashPage(),
    Routes.onboarding: (_) => OnboardingPage(),
    Routes.main: (_) => MainPage.create(),
    Routes.dialer: (_) => const DialerPage(isInBottomNavBar: false),
    Routes.feedback: (_) => const FeedbackPage(),
  };
}
