import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/app/pages/main/widgets/dial_pad/key_input.dart';
import 'package:vialer/app/resources/localizations.dart';
import 'package:vialer/app/widgets/brand_provider/widget.dart';
import 'package:vialer/domain/user/brand.dart';

void main() {
  final controller = TextEditingController();
  final testWidget = MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: [
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
          url: Uri.parse('https://partner.voipgrid.nl'),
          middlewareUrl: Uri.parse('https://vialerpush.voipgrid.nl'),
          voipgridUrl: Uri.parse('https://partner.voipgrid.nl'),
          encryptedSipUrl: Uri.parse('sip.encryptedsip.com'),
          unencryptedSipUrl: Uri.parse('sipproxy.voipgrid.nl'),
          businessAvailabilityUrl: Uri.parse(
              'https://api.eu-prod.holodeck.wearespindle.com/business-availability/clients/'),
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
    'Keyinput takes input via controller and updates properly',
    (tester) async {
      await tester.pumpWidget(testWidget);
      final testString = '+31612345678';
      controller.text = testString;
      await tester.pump();

      expect(find.widgetWithText(KeyInput, testString), findsOneWidget);
    },
  );
}
