import 'package:test/test.dart';
import 'package:vialer/app/util/reconnection_strategy.dart';

void main() {
  test(
    'It generates a valid reconnection strategy schedule without jitter',
    () async {
      final schedule = ReconnectionStrategy(defaultPattern).schedule;

      expect(
        schedule,
        [
          _fromSeconds(10.0),
          _fromSeconds(12.5),
          _fromSeconds(15.625),
          _fromSeconds(19.53125),
          _fromSeconds(24.4140625),
          _fromSeconds(30.517578125),
          _fromSeconds(38.14697265625),
          _fromSeconds(47.6837158203125),
          _fromSeconds(59.604644775390625),
          _fromSeconds(74.50580596923828),
        ],
      );
    },
  );

  test('It can provide the delay for a specific attempt', () async {
    final strategy = ReconnectionStrategy(defaultPattern);

    expect(strategy.delayFor(), _fromSeconds(10));
    strategy.increment();
    expect(strategy.delayFor(), _fromSeconds(12.5));
  });

  test('Will stop increasing when exceeding max back off', () async {
    final strategy = ReconnectionStrategy(defaultPattern);

    expect(strategy.delayFor(), _fromSeconds(10));
    for (var i = 0; i <= 100; i++) {
      strategy.increment();
    }
    expect(strategy.delayFor(), _fromSeconds(74.50580596923828));
  });

  test('Jitter provides different values', () async {
    final pattern = defaultPattern.copyWith(
      jitter: true,
      jitterMaxPercent: 30,
    );

    final schedules = <Duration>[];

    final generateAmount = 500;

    for (var i = 0; i < generateAmount; i++) {
      schedules.add(ReconnectionStrategy(pattern).schedule.first);
    }

    // We're basically finding all the unique values and asserting that
    // there is more than 1 of them which is expected if we're applying jitter.
    // It is technically possible that this test could fail but that would
    // require generating the same value [generateAmount] times which is
    // very unlikely.
    expect(schedules.toSet().toList().length, greaterThan(1));
  });
}

const defaultPattern = RetryPattern(
  initialDelay: Duration(seconds: 10),
  maxBackOff: 10,
  jitter: false,
);

Duration _fromSeconds(double seconds) =>
    Duration(milliseconds: (seconds * 1000).toInt());
