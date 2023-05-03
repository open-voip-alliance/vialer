import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vialer/app/main.dart' as app;
import 'package:vialer/app/main.dart';
import 'package:vialer/app/pages/main/page.dart';
import 'package:vialer/app/pages/onboarding/info/page.dart';
import 'package:vialer/app/pages/onboarding/login/page.dart';
import 'package:vialer/app/pages/onboarding/mobile_number/page.dart';
import 'package:vialer/app/pages/onboarding/page.dart';
import 'package:vialer/domain/onboarding/step.dart';

Future<void> runTest(
  List<String> name,
  WidgetTesterCallback test,
) async {
  assert(name.isNotEmpty, 'name must not be empty');

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  unawaited(app.main());

  final fullName = name
      .mapIndexed((index, part) => index != name.lastIndex ? '$part: ' : part)
      .joinToString(separator: ' ');

  testWidgets(fullName, test);
}

class _IsInflatedMatcher extends Matcher {
  const _IsInflatedMatcher();

  @override
  Description describe(Description description) =>
      description.add('the widget(s) found are inflated');

  @override
  Description describeMismatch(
    covariant Finder item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    var newDescription = mismatchDescription;
    for (final e in item.evaluate()) {
      if (e.size == Size.zero) {
        newDescription = newDescription.add('$e is not inflated');
      }
    }

    return newDescription;
  }

  @override
  bool matches(covariant Finder item, Map<dynamic, dynamic> matchState) =>
      item.evaluate().every((e) => e.size != Size.zero);
}

/// Asserts that the widget(s) found are inflated.
///
/// By "inflated", it's meant that the widget has a size. It does not check
/// whether the widget(s) are actually visible on screen.
const Matcher isInflated = _IsInflatedMatcher();

@immutable
class TestUser {
  const TestUser(this.email, this.password);

  final String email;
  final String password;
}

TestUser? _tester1;
TestUser? _tester2;
TestUser? _testUserWithoutAppAccount;

TestUser get testUser1 => _tester1 ??= TestUser(
      dotenv.env['TEST_USER_1_EMAIL']!,
      dotenv.env['TEST_USER_1_PASSWORD']!,
    );

TestUser get testUser2 => _tester2 ??= TestUser(
      dotenv.env['TEST_USER_2_EMAIL']!,
      dotenv.env['TEST_USER_2_PASSWORD']!,
    );

TestUser get testUserWithoutAppAccount =>
    _testUserWithoutAppAccount ??= TestUser(
      dotenv.env['TEST_USER_WITHOUT_APP_ACCOUNT_EMAIL']!,
      dotenv.env['TEST_USER_WITHOUT_APP_ACCOUNT_PASSWORD']!,
    );

extension OnboardingPageTesting on GlobalKey<OnboardingPageState> {
  /// Returns `null` if the onboarding is finished (and the OnboardingPage
  /// is not in the widget tree anymore).
  OnboardingStep? get currentStep => currentState?.currentPages.keys
      .elementAt(currentState!.pageController.page!.round());
}

extension Util on WidgetTester {
  Future<void> waitForOnboardingIntroAnimation() =>
      pumpAndSettle(const Duration(seconds: 10));

  /// Go through the onboarding process, by default as [testUser1].
  ///
  /// This method will return once the main page is shown.
  Future<void> completeOnboarding({TestUser? as}) async {
    // Await intro animation and letting the app initialize.
    await waitForOnboardingIntroAnimation();

    final user = as ?? testUser1;

    await enterText(
      find.byKey(LoginPage.keys.emailField),
      user.email,
    );

    await enterText(
      find.byKey(LoginPage.keys.passwordField),
      user.password,
    );

    const pageTransitionDuration = Duration(milliseconds: 2500);

    await tap(find.byKey(LoginPage.keys.loginButton));
    await pumpAndSettle(pageTransitionDuration);

    await tap(find.byKey(MobileNumberPage.keys.continueButton));
    await pumpAndSettle(pageTransitionDuration);

    OnboardingStep? onboardingStep() => OnboardingPage.keys.page.currentStep;

    // Go through call, contacts and microphone permission pages.
    while (onboardingStep() != null &&
        onboardingStep() != OnboardingStep.welcome) {
      await tap(find.byKey(InfoPage.keys.continueButton));
      await pumpAndSettle(pageTransitionDuration);
    }

    await pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> navigateTo(MainPageTab tab) async {
    App.navigateTo(tab);
    await pumpAndSettle(const Duration(seconds: 1));
  }
}
