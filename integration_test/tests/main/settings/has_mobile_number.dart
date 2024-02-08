import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/presentation/features/settings/pages/settings.dart';

import '../../../util.dart';

Future<void> main() => runTest(
      ['Main', 'Settings', 'Has mobile number'],
      (tester) async {
        await tester.completeOnboarding();

        // Not necessary to navigate to the Settings page, it's already
        // inflated.

        expect(find.byKey(SettingsPage.keys.mobileNumber), isInflated);
      },
    );
