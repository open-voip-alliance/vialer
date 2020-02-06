import 'main/dialer/page.dart';
import 'main/page.dart';
import 'onboarding/page.dart';
import 'widgets/redirect.dart';

abstract class Routes {
  static const root = '/';
  static const onboarding = '/onboarding';

  static const main = '/main';

  static const dialer = '/dialer';

  static final mapped = {
    Routes.root: (_) => Redirect(),
    Routes.onboarding: (_) => OnboardingPage(),
    Routes.main: (_) => MainPage(),
    Routes.dialer: (_) => DialerPage.create(),
  };
}
