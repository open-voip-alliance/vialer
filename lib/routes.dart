import 'package:flutter/material.dart';

import 'onboarding/page.dart';
import 'widgets/redirect.dart';

abstract class Routes {
  static const root = '/';
  static const onboarding = '/onboarding';

  static const dialer = '/dialer';

  static final mapped = {
    Routes.root: (_) => Redirect(),
    Routes.onboarding: (_) => OnboardingPage(),
    Routes.dialer: (_) => Container(),
  };
}
