import 'package:drift/drift.dart';
import 'package:test/test.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/authentication/logout.dart';
import 'package:vialer/domain/call_records/call_record.dart';
import 'package:vialer/domain/call_records/client/database/client_calls.dart';
import 'package:vialer/domain/call_records/client/local_client_calls.dart';

import '../../../../integration_test/util.dart';

void main() => runTest(
      ['Domain', 'Call records', 'Call records purged on logout'],
      (tester) async {
        const sourceNumber = '123';
        const destinationNumber = '543';

        final logout = Logout();

        final localClientCalls =
            dependencyLocator<LocalClientCallsRepository>();

        // Login with the test user.
        await tester.completeOnboarding();

        // Add call records for the user
        final callCompanionRecords = _generateDummyClientCallsCompanion(
          sourceNumber,
          destinationNumber,
        );
        localClientCalls.storeCallRecords(callCompanionRecords);

        await logout();

        final callRecords = await localClientCalls.getCalls(
          perPage: 10,
          onlyMissedCalls: false,
        );

        // Verify that the call records has been purged after logout.
        expect(0, callRecords.length);
      },
    );

List<ClientCallsCompanion> _generateDummyClientCallsCompanion(
  String sourceNumber,
  String destinationNumber,
) =>
    [
      ClientCallsCompanion(
        id: const Value(1),
        callType: const Value(CallType.outside),
        direction: const Value(Direction.outbound),
        answered: const Value(false),
        duration: const Value(0),
        date: Value(DateTime.now()),
        sourceNumber: Value(sourceNumber),
        sourceAccountId: const Value(1185079),
        destinationNumber: Value(destinationNumber),
        dialedNumber: Value(destinationNumber),
        destinationAccountId: const Value(null),
        callerNumber: Value(sourceNumber),
        callerId: const Value('Awesomesauce'),
        originalCallerId: const Value('Awesomesauce'),
        isSourceAccountLoggedInUser: const Value(false),
        isDestinationAccountLoggedInUser: const Value(false),
      ),
    ];
