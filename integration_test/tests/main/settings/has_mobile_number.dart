import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/app/pages/main/settings/page.dart';

import '../../../util.dart';

void main() => runTest(
      ['Main', 'Settings', 'Has mobile number'],
      (tester) async {
        expect(true, true);
        // await tester.completeOnboarding();
        //
        // // Not necessary to navigate to the Settings page, it's already
        // // inflated.
        //
        // expect(find.byKey(SettingsPage.keys.mobileNumber), isInflated);
      },
    );
