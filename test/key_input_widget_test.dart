import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:vialer/app/pages/main/dialer/widgets/key_input.dart';
import 'package:vialer/app/widgets/brand_provider/widget.dart';
import 'package:vialer/domain/entities/brand.dart';

void main() {
  final controller = TextEditingController();
  final testWidget = MaterialApp(
    home: Scaffold(
      body: BrandProvider(
        brand: Brand(
          identifier: 'vialer',
          appName: 'Vialer',
          url: Uri.parse('https://partner.voipgrid.nl'),
        ),
        child: KeyInput(
          controller: controller,
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
