import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/data/models/user/brand.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/widgets/brand_provider/widget.dart';
import 'package:vialer/presentation/shared/widgets/dial_pad/keypad.dart';

void main() {
  final textController = TextEditingController();
  final keypad = Localizations(
    locale: const Locale('en'),
    delegates: const [
      VialerLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    child: Keypad(
      controller: textController,
      cursorShownNotifier: ValueNotifier(false),
      bottomCenterButton: GestureDetector(
        onTap: () => initiateFakeCall(controller: textController),
      ),
    ),
  );

  final testWidget = TestApp(
    child: Column(
      children: <Widget>[
        keypad,
        TextField(
          controller: textController,
        ),
      ],
    ),
  );

  group('Keypad has all the expected buttons', () {
    testWidgets('12 keypad buttons', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.byType(Keypad),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(Keypad),
          matching: find.byType(KeypadValueButton),
        ),
        findsNWidgets(12),
      );
    });
  });

  group('Keypad buttons are in correct order and have correct labels', () {
    testWidgets('1st Button: 1', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(0),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('2nd button: 2 / ABC', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(1),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(1),
          matching: find.text('ABC'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('3rd button: 3 / DEF', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(2),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(2),
          matching: find.text('DEF'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('4th button: 4 / GHI', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(3),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(3),
          matching: find.text('GHI'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('5th button 5 / JKL', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(4),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(4),
          matching: find.text('JKL'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('6th button: 6 / MNO', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(5),
          matching: find.text('6'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(5),
          matching: find.text('MNO'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('7th button: 7 / PQRS', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(6),
          matching: find.text('7'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(6),
          matching: find.text('PQRS'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('8th button 8 / TUV', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(7),
          matching: find.text('8'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(7),
          matching: find.text('TUV'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('9th button: 9 / WXYZ', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(8),
          matching: find.text('9'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(8),
          matching: find.text('WXYZ'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('10th button: *', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(9),
          matching: find.text('*'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('11th button: 0 / +', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(10),
          matching: find.text('0'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(10),
          matching: find.text('+'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('12th button: #', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.descendant(
          of: find.byType(KeypadValueButton).at(11),
          matching: find.text('#'),
        ),
        findsOneWidget,
      );
    });
  });

  group('Buttons press produces correct output', () {
    tearDown(() {
      textController.text = '';
    });

    testWidgets('Longpress 0 -> +', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.longPress(find.widgetWithText(KeypadValueButton, '0'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '+'),
        findsOneWidget,
      );
    });

    testWidgets('Press 0', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '0'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '0'),
        findsOneWidget,
      );
    });

    testWidgets('Press 1', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '1'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '1'),
        findsOneWidget,
      );
    });

    testWidgets('Press 2', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '2'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '2'),
        findsOneWidget,
      );
    });

    testWidgets('Press 3', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '3'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '3'),
        findsOneWidget,
      );
    });

    testWidgets('Press 4', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '4'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '4'),
        findsOneWidget,
      );
    });

    testWidgets('Press 5', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '5'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextField, '5'),
        findsOneWidget,
      );
    });

    testWidgets('Press 6', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '6'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '6'),
        findsOneWidget,
      );
    });

    testWidgets('Press 7', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '7'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '7'),
        findsOneWidget,
      );
    });

    testWidgets('Press 8', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '8'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '8'),
        findsOneWidget,
      );
    });

    testWidgets('Press 9', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '9'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '9'),
        findsOneWidget,
      );
    });

    testWidgets('Press *', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '*'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '*'),
        findsOneWidget,
      );
    });

    testWidgets('Press #', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(KeypadValueButton, '#'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '#'),
        findsOneWidget,
      );
    });

    testWidgets('Press All keypad buttons', (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.longPress(find.widgetWithText(KeypadValueButton, '0'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '0'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '1'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '2'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '3'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '4'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '5'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '6'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '7'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '8'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '9'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '*'));
      await tester.tap(find.widgetWithText(KeypadValueButton, '#'));
      await tester.pump();
      expect(
        find.widgetWithText(TextField, '+0123456789*#'),
        findsOneWidget,
      );
    });
  });
}

void initiateFakeCall({required TextEditingController controller}) {
  controller.text = 'Call started';
}

class TestApp extends StatelessWidget {
  TestApp({
    required this.child,
    super.key,
  });

  final Widget child;
  final _fakeUrl = Uri.parse('https://fake.url');

  @override
  Widget build(BuildContext context) {
    return BrandProvider(
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
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: context.brand.appName,
            theme: context.brand.theme.themeData,
            home: Scaffold(
              body: child,
            ),
          );
        },
      ),
    );
  }
}
