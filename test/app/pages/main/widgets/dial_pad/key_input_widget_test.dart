import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/data/models/user/brand.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/shared/widgets/brand_provider/widget.dart';
import 'package:vialer/presentation/shared/widgets/dial_pad/key_input.dart';

void main() {
  final _fakeUrl = Uri.parse('https://fake.url');
  final controller = TextEditingController();
  final testWidget = MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      VialerLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: BrandProvider(
        brand: Brand(
          identifier: 'vialer',
          appId: 'com.voipgrid.vialer',
          appName: 'Vialer',
          url: _fakeUrl,
          middlewareUrl: _fakeUrl,
          voipgridUrl: _fakeUrl,
          sipUrl: _fakeUrl,
          businessAvailabilityUrl: _fakeUrl,
          openingHoursBasicUrl: _fakeUrl,
          resgateUrl: _fakeUrl,
          privacyPolicyUrl: _fakeUrl,
          signUpUrl: null,
          availabilityServiceUrl: _fakeUrl,
          sharedContactsUrl: _fakeUrl,
          phoneNumberValidationUrl: _fakeUrl,
          featureAnnouncementsUrl: _fakeUrl,
          supportUrl: _fakeUrl,
          supportUrlNL: _fakeUrl,
        ),
        child: KeyInput(
          controller: controller,
          cursorShownNotifier: ValueNotifier(false),
        ),
      ),
    ),
  );

  testWidgets('KeyInput is initialized with empty content', (tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.widgetWithText(KeyInput, ''), findsOneWidget);
  });

  testWidgets(
    'KeyInput takes input via controller and updates properly',
    (tester) async {
      await tester.pumpWidget(testWidget);
      const testString = '+31612345678';
      controller.text = testString;
      await tester.pump();

      expect(find.widgetWithText(KeyInput, testString), findsOneWidget);
    },
  );
}
