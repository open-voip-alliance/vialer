import 'package:flutter/material.dart';

import 'features/dialer/dialer_page.dart';
import 'features/main_page.dart';
import 'features/onboarding/widgets/page.dart';

abstract class Routes {
  static const onboarding = '/onboarding';
  static const main = '/main';
  static const dialer = '/dialer';

  static final mapped = <String, WidgetBuilder>{
    Routes.onboarding: (_) => OnboardingPage(),
    Routes.main: (_) => MainPage(),
    Routes.dialer: (_) => const DialerPage(isInBottomNavBar: false),
  };
}
