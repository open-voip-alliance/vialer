import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vialer/app/util/automatic_retry.dart';

@GenerateNiceMocks([MockSpec<DummyClass>()])
import 'automatic_retry_test.mocks.dart';

void main() {
  test('A task does not retry if it succeeds', () async {
    final automaticRetry = AutomaticRetry(
      schedule: const [Duration(milliseconds: 50)],
    );
    final mock = MockDummyClass();
    when(mock.getResult()).thenReturn('A value');

    await automaticRetry.run(() async => mock.getResult());
    verify(mock.getResult()).called(1);
  });

  test('A task ends even if there is no schedule', () async {
    final automaticRetry = AutomaticRetry(schedule: []);
    final mock = MockDummyClass();
    when(mock.getResult()).thenThrow(TaskFailedQueueForRetry());

    await _expectMaximumAttemptsReached(automaticRetry, mock);
  });

  test('Argument error is thrown if no schedule and not running immediately',
      () async {
    final automaticRetry = AutomaticRetry(schedule: []);
    final mock = MockDummyClass();
    when(mock.getResult()).thenThrow(TaskFailedQueueForRetry());

    await _expectArgumentError(
      () => automaticRetry.run(
        () async => mock.getResult(),
        runImmediately: false,
      ),
    );
  });

  test('A task will retry according to schedule if it fails', () async {
    final automaticRetry = AutomaticRetry(
      schedule: const [
        Duration(milliseconds: 10),
        Duration(milliseconds: 20),
        Duration(milliseconds: 30),
      ],
    );
    final mock = MockDummyClass();
    when(mock.getResult()).thenThrow(TaskFailedQueueForRetry());

    await _expectMaximumAttemptsReached(automaticRetry, mock);
    verify(mock.getResult()).called(4);
  });

  test('A task will stop retrying if it completes successfully', () async {
    final automaticRetry = AutomaticRetry(
      schedule: const [
        // We want to make sure the schedule is full as only the first two
        // in the schedule should be called.
        Duration(milliseconds: 10),
        Duration(milliseconds: 20),
        Duration(milliseconds: 30),
        Duration(milliseconds: 40),
        Duration(milliseconds: 50),
        Duration(milliseconds: 60),
      ],
    );
    final mock = MockDummyClass();

    // There is no in-built mechanism in Mockito to provide different responses
    // depending on how many times it is called, so we will have to fake it
    // with this local variable.
    var runs = 0;
    when(mock.getResult()).thenAnswer((_) {
      if (runs < 2) {
        runs++;
        throw TaskFailedQueueForRetry();
      }

      return 'A valid value';
    });

    expect(
      await automaticRetry.run(() async => mock.getResult()),
      'A valid value',
    );
    verify(mock.getResult()).called(3);
  });

  test('Running a task again will cancel all existing retries', () async {
    final automaticRetry = AutomaticRetry(schedule: const [
      Duration(milliseconds: 50),
    ]);
    final failingMock = MockDummyClass();
    when(failingMock.getResult()).thenThrow(TaskFailedQueueForRetry());

    automaticRetry.run(
      () async => failingMock.getResult(),
      runImmediately: false,
    );

    final successMock = MockDummyClass();
    when(successMock.getResult()).thenReturn('A value');

    automaticRetry.run(
      () async {
        return successMock.getResult();
      },
    );

    // The first mock should never get called as [runImmediately] is false.
    verifyNever(failingMock.getResult());
    verify(successMock.getResult()).called(1);
  });
}

Future<void> _expectArgumentError(Future<String> Function() callback) =>
    expectLater(
      callback,
      throwsA(isA<ArgumentError>()),
    );

Future<void> _expectMaximumAttemptsReached(
  AutomaticRetry automaticRetry,
  MockDummyClass mock,
) async =>
    expectLater(
      () => automaticRetry.run(() async => mock.getResult()),
      throwsA(isA<AutomaticRetryMaximumAttemptsReached>()),
    );

// A dummy class just used so we can mock it and verify interactions, it needs
// to be public so it can be mocked.
class DummyClass {
  String getResult() => '';
}
