import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

import 'package:vialer_lite/app/pages/main/dialer/widgets/keypad.dart';
import 'package:vialer_lite/app/resources/theme.dart';
import 'package:vialer_lite/domain/entities/brand.dart';

void main() {
  final textController = TextEditingController();
  final onCallButtonPressed = initateFakeCall;
  final keypad = Keypad(
    controller: textController,
    onCallButtonPressed: () => onCallButtonPressed(controller: textController),
  );
  final testWidget = TestApp(
      child: Row(
    children: <Widget>[
      Drawer(child: keypad),
      Drawer(
        child: TextField(controller: textController),
      ),
    ],
  ));

  group('Keypad has all the expected buttons', () {
    testWidgets('12 keypad buttons', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byType(Keypad), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Keypad),
          matching: find.byType(ValueButton),
        ),
        findsNWidgets(12),
      );
    });

    testWidgets('Call button', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byIcon(VialerSans.phone), findsOneWidget);
    });

    testWidgets('Delete button', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byIcon(VialerSans.correct), findsOneWidget);
    });
  });

  group('Keypad buttons are in correct order and have correct labels', () {
    testWidgets('1st Button: 1', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(0),
            matching: find.text('1'),
          ),
          findsOneWidget);
    });
    testWidgets('2nd button: 2 / ABC', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(1),
            matching: find.text('2'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(1),
            matching: find.text('ABC'),
          ),
          findsOneWidget);
    });

    testWidgets('3rd button: 3 / DEF', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(2),
            matching: find.text('3'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(2),
            matching: find.text('DEF'),
          ),
          findsOneWidget);
    });

    testWidgets('4th button: 4 / GHI', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(3),
            matching: find.text('4'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(3),
            matching: find.text('GHI'),
          ),
          findsOneWidget);
    });

    testWidgets('5th button 5 / JKL', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(4),
            matching: find.text('5'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(4),
            matching: find.text('JKL'),
          ),
          findsOneWidget);
    });

    testWidgets('6th button: 6 / MNO', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(5),
            matching: find.text('6'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(5),
            matching: find.text('MNO'),
          ),
          findsOneWidget);
    });

    testWidgets('7th button: 7 / PQRS', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(6),
            matching: find.text('7'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(6),
            matching: find.text('PQRS'),
          ),
          findsOneWidget);
    });

    testWidgets('8th button 8 / TUV', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(7),
            matching: find.text('8'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(7),
            matching: find.text('TUV'),
          ),
          findsOneWidget);
    });

    testWidgets('9th button: 9 / WXYZ', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(8),
            matching: find.text('9'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(8),
            matching: find.text('WXYZ'),
          ),
          findsOneWidget);
    });

    testWidgets('10th button: *', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(9),
            matching: find.text('*'),
          ),
          findsOneWidget);
    });

    testWidgets('11th button: 0 / +', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(10),
            matching: find.text('0'),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(ValueButton).at(10),
            matching: find.text('+'),
          ),
          findsOneWidget);
    });

    testWidgets('12th button: #', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.descendant(
            of: find.byType(ValueButton).at(11),
            matching: find.text('#'),
          ),
          findsOneWidget);
    });
  });

  group('Buttons press produces correct output', () {
    tearDown(() {
      textController.text = '';
    });
    testWidgets('Longpress 0 -> +', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.longPress(find.widgetWithText(ValueButton, '0'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '+'), findsOneWidget);
    });

    testWidgets('Press 0', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '0'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '0'), findsOneWidget);
    });

    testWidgets('Press 1', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '1'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '1'), findsOneWidget);
    });

    testWidgets('Press 2', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '2'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    });

    testWidgets('Press 3', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '3'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '3'), findsOneWidget);
    });
    testWidgets('Press 4', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '4'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '4'), findsOneWidget);
    });
    testWidgets('Press 5', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '5'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '5'), findsOneWidget);
    });
    testWidgets('Press 6', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '6'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '6'), findsOneWidget);
    });

    testWidgets('Press 7', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '7'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '7'), findsOneWidget);
    });

    testWidgets('Press 8', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '8'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '8'), findsOneWidget);
    });

    testWidgets('Press 9', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '9'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '9'), findsOneWidget);
    });

    testWidgets('Press *', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '*'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '*'), findsOneWidget);
    });

    testWidgets('Press #', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.tap(find.widgetWithText(ValueButton, '#'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '#'), findsOneWidget);
    });

    testWidgets('Press All keypad buttons', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.longPress(find.widgetWithText(ValueButton, '0'));
      await tester.tap(find.widgetWithText(ValueButton, '0'));
      await tester.tap(find.widgetWithText(ValueButton, '1'));
      await tester.tap(find.widgetWithText(ValueButton, '2'));
      await tester.tap(find.widgetWithText(ValueButton, '3'));
      await tester.tap(find.widgetWithText(ValueButton, '4'));
      await tester.tap(find.widgetWithText(ValueButton, '5'));
      await tester.tap(find.widgetWithText(ValueButton, '6'));
      await tester.tap(find.widgetWithText(ValueButton, '7'));
      await tester.tap(find.widgetWithText(ValueButton, '8'));
      await tester.tap(find.widgetWithText(ValueButton, '9'));
      await tester.tap(find.widgetWithText(ValueButton, '*'));
      await tester.tap(find.widgetWithText(ValueButton, '#'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '+0123456789*#'), findsOneWidget);
    });

    testWidgets('Press delete', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      textController.text = '+0123456789';
      await tester.pump();
      await tester.tap(find.ancestor(
          of: find.byIcon(VialerSans.correct),
          matching: find.byType(InkResponse)));
      expect(find.widgetWithText(TextField, '+012345678'), findsOneWidget);
    });

    testWidgets('Longpress delete', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      textController.text = '+0123456789';
      await tester.pump();
      await tester.longPress(find.ancestor(
          of: find.byIcon(VialerSans.correct),
          matching: find.byType(InkResponse)));
      expect(find.widgetWithText(TextField, ''), findsOneWidget);
    });

    testWidgets('Press call button', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      textController.text = '+0123456789';
      await tester.pump();
      await tester.tap(find.ancestor(
          of: find.byIcon(VialerSans.phone),
          matching: find.byType(FloatingActionButton)));
      expect(find.widgetWithText(TextField, 'Call started'), findsOneWidget);
    });
  });
}

void initateFakeCall({TextEditingController controller}) {
  controller.text = 'Call started';
}

class TestApp extends StatelessWidget {
  final Widget child;
  final BrandTheme theme = VoysTheme();

  TestApp({this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Brand>.value(
          value: Voys(),
        ),
        Provider<BrandTheme>(
          create: (_) => VoysTheme(),
        ),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          title: Provider.of<Brand>(context).appName,
          theme: context.brandTheme.themeData,
          home: child,
        );
      }),
    );
  }
}
