import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vialer/domain/call_records/call_record.dart';
import 'package:vialer/domain/call_records/item.dart';
import 'package:vialer/domain/colltacts/contact.dart';
import 'package:vialer/domain/colltacts/contact_populator.dart';
import 'package:vialer/domain/colltacts/contact_repository.dart';

@GenerateNiceMocks([MockSpec<ContactRepository>()])
import 'contact_populator_test.mocks.dart';

void main() {
  /// These are the two types of numbers we need to worry about as the API
  /// should always return them formatted in these two ways.
  const externalNumber = '+31640366644';
  const internalNumber = '241';

  test('External number matches contact number exactly', () {
    _expectsToMatchContact(
      numberInCallRecord: externalNumber,
      numbersInContacts: [externalNumber],
    );
  });

  test('Internal number matches contact number exactly', () {
    _expectsToMatchContact(
      numberInCallRecord: internalNumber,
      numbersInContacts: [internalNumber],
    );
  });

  test('External number matches contact without country code', () {
    _expectsToMatchContact(
      numberInCallRecord: externalNumber,
      numbersInContacts: ['0640366644'],
    );
  });

  test('Internal number does not match with country code', () {
    _expectsNotToMatchContact(
      numberInCallRecord: internalNumber,
      numbersInContacts: ['+31241'],
    );
  });
}

void _expectsToMatchContact({
  required String numberInCallRecord,
  required List<String> numbersInContacts,
}) =>
    unawaited(
      _expectContactMatching(
        numberInCallRecord,
        numbersInContacts,
        shouldMatch: true,
      ),
    );

void _expectsNotToMatchContact({
  required String numberInCallRecord,
  required List<String> numbersInContacts,
}) =>
    unawaited(
      _expectContactMatching(
        numberInCallRecord,
        numbersInContacts,
        shouldMatch: false,
      ),
    );

Future<void> _expectContactMatching(
  String numberInCallRecord,
  List<String> numbersInContacts, {
  required bool shouldMatch,
}) async {
  final records = _generateDummyCallRecordsForNumber(numberInCallRecord);
  final result = await CallRecordContactPopulator(
    await _createMockWithStoredNumbers(numbersInContacts),
  ).populate(records);
  expect(
    result.first.contact,
    shouldMatch ? isNotNull : isNull,
    reason: shouldMatch
        ? 'Unable to find match for '
            '"$numberInCallRecord" in $numbersInContacts'
        : 'Match found for "$numberInCallRecord" '
            'in $numbersInContacts when one was not expected.',
  );
}

List<CallRecord> _generateDummyCallRecordsForNumber(String number) => [
      CallRecordWithoutContact(
        id: 'dummyId',
        callType: CallType.colleague,
        callDirection: Direction.inbound,
        answered: true,
        answeredElsewhere: false,
        duration: const Duration(seconds: 5),
        date: DateTime.now(),
        caller: CallParty(
          name: 'CallerName',
          number: number,
          type: CallerType.app,
        ),
        destination: CallParty(
          name: 'CallerName',
          number: number,
          type: CallerType.app,
        ),
      ),
    ];

Future<MockContactRepository> _createMockWithStoredNumbers(
  List<String> numbers,
) async {
  final contactRepositoryMock = MockContactRepository();

  when(contactRepositoryMock.getContacts()).thenAnswer(
    (_) async => numbers.map(_generateDummyContact).toList(),
  );

  return contactRepositoryMock;
}

Contact _generateDummyContact(String number) => Contact(
      givenName: 'Foo',
      middleName: 'Bar',
      familyName: 'Baz',
      chosenName: 'Fred',
      phoneNumbers: [
        Item(label: 'Mobile', value: number),
      ],
      emails: [
        const Item(label: 'Main', value: 'foo@acme.com'),
      ],
      identifier: '123',
      company: 'acme',
      avatarPath: null,
    );
