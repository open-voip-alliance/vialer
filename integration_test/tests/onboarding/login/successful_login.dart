import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/app/pages/onboarding/login/page.dart';
import 'package:vialer/app/pages/onboarding/mobile_number/page.dart';
import 'package:vialer/app/pages/onboarding/page.dart';
import 'package:vialer/domain/entities/onboarding/step.dart';

import '../../../util.dart';

void main() =>
    runTest(['Onboarding', 'Login', 'Successful login'], (tester) async {
      await tester.waitForOnboardingIntroAnimation();

      expect(find.byKey(MobileNumberPage.keys.field), isInflated);

      await tester.enterText(
        find.byKey(LoginPage.keys.emailField),
        testUser1.email,
      );

      await tester.enterText(
        find.byKey(LoginPage.keys.passwordField),
        testUser1.password,
      );

      await tester.tap(find.byKey(LoginPage.keys.loginButton));

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(OnboardingPage.keys.page.currentStep, OnboardingStep.mobileNumber);
    });
