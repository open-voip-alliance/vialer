import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/app/pages/onboarding/login/page.dart';
import 'package:vialer/app/pages/onboarding/mobile_number/page.dart';
import 'package:vialer/app/pages/onboarding/page.dart';
import 'package:vialer/domain/onboarding/step.dart';

import '../../../util.dart';

Future<void> main() => performLoginTestWith(
      username: () => testUser1.email,
      password: () => testUser1.password,
    );

// This needs to accept a callback to provide the login credentials otherwise
// dotenv is not yet configured.
Future<void> performLoginTestWith({
  required String Function() username,
  required String Function() password,
}) =>
    runTest(['Onboarding', 'Login', 'Successful login'], (tester) async {
      await tester.waitForOnboardingIntroAnimation();

      expect(find.byKey(MobileNumberPage.keys.field), isInflated);

      await tester.enterText(
        find.byKey(LoginPage.keys.emailField),
        username(),
      );

      await tester.enterText(
        find.byKey(LoginPage.keys.passwordField),
        password(),
      );

      await tester.tap(find.byKey(LoginPage.keys.loginButton));

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(OnboardingPage.keys.page.currentStep, OnboardingStep.mobileNumber);
    });
