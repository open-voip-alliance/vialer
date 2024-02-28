import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/data/models/user/brand.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/shared/widgets/brand_provider/widget.dart';
import 'package:vialer/presentation/shared/widgets/dial_pad/key_input.dart';

void main() {
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
          url: Uri.parse('https://partner.voipgrid.nl'),
          middlewareUrl: Uri.parse('https://vialerpush.voipgrid.nl'),
          voipgridUrl: Uri.parse('https://partner.voipgrid.nl'),
          sipUrl: Uri.parse('sip.encryptedsip.com'),
          businessAvailabilityUrl: Uri.parse(
            'https://api.eu-prod.holodeck.wearespindle.com/business-availability/clients/',
          ),
          openingHoursBasicUrl: Uri.parse(
            'https://api.eu-prod.holodeck.wearespindle.com/openinghours/client/',
          ),
          resgateUrl: Uri.parse('resgate'),
          privacyPolicyUrl: Uri.parse('dummypolicy.com'),
          signUpUrl: null,
          availabilityServiceUrl: Uri.parse('dummydndservice.url'),
          sharedContactsUrl:
              Uri.parse('https://contacts.spindle.dev/contacts/'),
          phoneNumberValidationUrl:
              Uri.parse('https://phonenumbers.spindle.dev'),
          featureAnnouncementsUrl: Uri.parse(
            "https://api.prod.holodeck.spindle.dev/feature-announcments/",
          ),
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
