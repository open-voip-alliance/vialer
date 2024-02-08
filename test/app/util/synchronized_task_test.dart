import 'dart:async';

import 'package:test/test.dart';
import 'package:vialer/presentation/util/synchronized_task.dart';

void main() {
  test('A task only executes the first future if already running', () async {
    var testValue = 0;

    final expectedRun = SynchronizedTask<void>.named('Testing').run(
      () async {
        testValue = 1;
        await Future<void>.delayed(const Duration(seconds: 1));
      },
    );

    final unexpectedRun1 = SynchronizedTask<void>.named('Testing').run(
      () async {
        testValue = 2;
      },
    );

    final unexpectedRun2 = SynchronizedTask<void>.named('Testing').run(
      () async {
        testValue = 2;
      },
    );

    final unexpectedRun3 = SynchronizedTask<void>.named('Testing').run(
      () async {
        testValue = 2;
      },
    );

    await Future.wait([
      expectedRun,
      unexpectedRun1,
      unexpectedRun2,
      unexpectedRun3,
    ]);

    expect(testValue, 1);
  });

  test('Get the result of an executed task', () async {
    const expected = 'expected return value';

    final value = await SynchronizedTask<String>.named('Testing').run(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return expected;
    });

    expect(value, expected);
  });

  test('Get result when in-progress task completes', () async {
    const expected = 'expected return value';

    unawaited(
      SynchronizedTask<String>.named('Testing').run(() async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return expected;
      }),
    );

    final value = await SynchronizedTask<String>.named('Testing').run(
      () async => 'should not be returned',
    );

    expect(value, expected);
  });

  test('Get result when in-progress task completes', () async {
    const expected = 'expected return value';

    unawaited(
      SynchronizedTask<String>.named('Testing').run(() async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return expected;
      }),
    );

    final value = await SynchronizedTask<String>.named('Testing').run(
      () async => 'should not be returned',
    );

    expect(value, expected);
  });

  test('Create a task based on object alone', () async {
    final object = _DummyClass();

    final task1 = SynchronizedTask<_DummyClass>.of(object);

    expect(task1.name, '_DummyClass');

    final task2 = SynchronizedTask<_DummyClass>.of(object);

    expect(task1.name, task2.name);
  });

  test('A task throwing an exception does not prevent others', () async {
    var testValue = 0;

    try {
      await SynchronizedTask<void>.named('Testing').run(() async {
        throw Exception('Testing exceptions');
      });
    } on Exception {
      // Catch.
    }

    await SynchronizedTask<void>.named('Testing').run(() async {
      testValue = 1;
    });

    expect(testValue, 1);
  });

  test('Tasks are queued properly in queue mode', () async {
    const mode = SynchronizedTaskMode.queue;
    // A string is used to test the order as well.
    var testValue = '0';

    final run1 = SynchronizedTask<void>.named('Testing', mode).run(() async {
      testValue += '1';
      await Future<void>.delayed(const Duration(seconds: 1));
    });

    final run2 = SynchronizedTask<void>.named('Testing', mode).run(() async {
      testValue += '2';
    });

    final run3 = SynchronizedTask<void>.named('Testing', mode).run(() async {
      testValue += '3';
    });

    final run4 = SynchronizedTask<void>.named('Testing', mode).run(() async {
      testValue += '4';
    });

    await Future.wait([run1, run2, run3, run4]);

    expect(testValue, '01234');
  });
}

class _DummyClass {}
