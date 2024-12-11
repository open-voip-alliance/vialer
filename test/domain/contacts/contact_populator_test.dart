import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vialer/data/models/call_records/call_record.dart';
import 'package:vialer/data/models/call_records/item.dart';
import 'package:vialer/data/models/colltacts/contact.dart';
import 'package:vialer/data/models/colltacts/contact_populator.dart';
import 'package:vialer/data/models/colltacts/shared_contacts/shared_contact.dart';
import 'package:vialer/data/repositories/colltacts/contact_repository.dart';
import 'package:vialer/data/repositories/legacy/storage.dart';

@GenerateNiceMocks([MockSpec<ContactRepository>()])
@GenerateNiceMocks([MockSpec<StorageRepository>()])
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

  test('External number matches shared contact number exactly', () {
    _expectsToMatchContact(
      numberInCallRecord: externalNumber,
      numbersInContacts: [],
      numbersInSharedContacts: [externalNumber],
    );
  });

  test('Internal number matches contact number exactly', () {
    _expectsToMatchContact(
      numberInCallRecord: internalNumber,
      numbersInContacts: [internalNumber],
    );
  });

  test('Internal number matches shared contact number exactly', () {
    _expectsToMatchContact(
      numberInCallRecord: internalNumber,
      numbersInContacts: [],
      numbersInSharedContacts: [internalNumber],
    );
  });

  test('External number matches contact without country code', () {
    _expectsToMatchContact(
      numberInCallRecord: externalNumber,
      numbersInContacts: ['0640366644'],
    );
  });

  test('External number matches shared contact without country code', () {
    _expectsToMatchContact(
      numberInCallRecord: externalNumber,
      numbersInContacts: [],
      numbersInSharedContacts: ['0640366644'],
    );
  });

  test('Internal number does not match with country code', () {
    _expectsNotToMatchContact(
      numberInCallRecord: internalNumber,
      numbersInContacts: ['+31241'],
    );
  });

  test('Internal number does not match with shared contact country code', () {
    _expectsNotToMatchContact(
      numberInCallRecord: internalNumber,
      numbersInContacts: [],
      numbersInSharedContacts: ['+31241'],
    );
  });
}

void _expectsToMatchContact({
  required String numberInCallRecord,
  required List<String> numbersInContacts,
  List<String> numbersInSharedContacts = const [],
}) =>
    unawaited(
      _expectContactMatching(
        numberInCallRecord,
        numbersInContacts,
        numbersInSharedContacts,
        shouldMatch: true,
      ),
    );

void _expectsNotToMatchContact({
  required String numberInCallRecord,
  required List<String> numbersInContacts,
  List<String> numbersInSharedContacts = const [],
}) =>
    unawaited(
      _expectContactMatching(
        numberInCallRecord,
        numbersInContacts,
        numbersInSharedContacts,
        shouldMatch: false,
      ),
    );

Future<void> _expectContactMatching(
  String numberInCallRecord,
  List<String> numbersInContacts,
  List<String> numbersInSharedContacts, {
  required bool shouldMatch,
}) async {
  final records = _generateDummyCallRecordsForNumber(numberInCallRecord);
  final result = await CallRecordContactPopulator(
    await _createMockWithStoredNumbers(numbersInContacts),
    await _createMockWithStorageRepository(numbersInSharedContacts),
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

Future<MockStorageRepository> _createMockWithStorageRepository(
  List<String> numbers,
) async {
  final contactRepositoryMock = MockStorageRepository();

  when(contactRepositoryMock.sharedContacts).thenAnswer(
    (_) => numbers.map(_generateDummySharedContact).toList(),
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

SharedContact _generateDummySharedContact(String number) => SharedContact(
      givenName: 'Foo',
      familyName: 'Baz',
      companyName: 'acme',
      phoneNumbers: [SharedContactPhoneNumber(phoneNumberFlat: number)],
      id: '123',
    );
