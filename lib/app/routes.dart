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
    Routes.root: (_) => SplashPage(),
    Routes.onboarding: (_) => OnboardingPage(),
    Routes.main: (_) => MainPage(),
    Routes.dialer: (_) => DialerPage(),
  };
}
