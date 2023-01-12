import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/app/pages/onboarding/info/page.dart';
import 'package:vialer/app/pages/onboarding/login/page.dart';
import 'package:vialer/app/pages/onboarding/mobile_number/page.dart';
import 'package:vialer/app/pages/onboarding/page.dart';
import 'package:vialer/domain/onboarding/step.dart';

import '../../../util.dart';

void main() => runTest([
      'Onboarding',
      'Login',
      'Successful login with no app account',
    ], (tester) async {
      await tester.waitForOnboardingIntroAnimation();

      expect(find.byKey(MobileNumberPage.keys.field), isInflated);

      await tester.enterText(
        find.byKey(LoginPage.keys.emailField),
        testUserNoAppAccount.email,
      );

      await tester.enterText(
        find.byKey(LoginPage.keys.passwordField),
        testUserNoAppAccount.password,
      );

      await tester.tap(find.byKey(LoginPage.keys.loginButton));

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(OnboardingPage.keys.page.currentStep, OnboardingStep.voicemail);

      await tester.tap(find.byKey(InfoPage.keys.continueButton));

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(OnboardingPage.keys.page.currentStep, OnboardingStep.welcome);
    });
