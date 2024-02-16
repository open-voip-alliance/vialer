import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/presentation/features/onboarding/pages/login/login_page.dart';

import '../../../util.dart';

Future<void> main() =>
    runTest(['Onboarding', 'Login', 'Wrong format'], (tester) async {
      await tester.waitForOnboardingIntroAnimation();

      await tester.tap(find.byKey(LoginPage.keys.loginButton));
      await tester.pumpAndSettle();

      expect(
        find.byKey(LoginPage.keys.wrongEmailFormatError),
        isInflated,
      );

      expect(
        find.byKey(LoginPage.keys.wrongPasswordFormatError),
        isInflated,
      );
    });
