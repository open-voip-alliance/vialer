import 'package:provider/provider.dart';

import '../domain/repositories/call.dart';
import '../domain/repositories/permission.dart';
import '../domain/repositories/auth.dart';

import 'pages/main/dialer/page.dart';
import 'pages/main/page.dart';
import 'pages/onboarding/page.dart';
import 'pages/splash/page.dart';

abstract class Routes {
  static const root = '/';
  static const onboarding = '/onboarding';

  static const main = '/main';

  static const dialer = '/dialer';

  static final mapped = {
    Routes.root: (c) => SplashPage(Provider.of<AuthRepository>(c)),
    Routes.onboarding: (c) =>
        OnboardingPage(Provider.of<PermissionRepository>(c)),
    Routes.main: (_) => MainPage(),
    Routes.dialer: (c) => DialerPage(Provider.of<CallRepository>(c)),
  };
}
