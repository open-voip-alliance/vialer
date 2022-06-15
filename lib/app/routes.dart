import 'package:flutter/material.dart';

import 'main.dart';
import 'pages/main/dialer/page.dart';
import 'pages/main/page.dart';
import 'pages/onboarding/page.dart';
import 'pages/splash/page.dart';

abstract class Routes {
  static const root = '/';
  static const onboarding = '/onboarding';

  static const main = '/main';

  static const dialer = '/dialer';

  static final mapped = <String, WidgetBuilder>{
    Routes.root: (_) => const SplashPage(),
    Routes.onboarding: (_) => const OnboardingPage(),
    Routes.main: (_) => MainPage.create(key: App.mainPageKey),
    Routes.dialer: (_) => const DialerPage(isInBottomNavBar: false),
  };
}
