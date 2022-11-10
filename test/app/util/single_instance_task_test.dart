import 'package:test/test.dart';
import 'package:vialer/app/util/single_task.dart';

void main() {
  test('A task only executes the first future if already running', () async {
    var testValue = 0;

    final expectedRun = SingleInstanceTask.named('Testing').run(() async {
      testValue = 1;
      Future.delayed(const Duration(seconds: 1));
    });

    final unexpectedRun1 = SingleInstanceTask.named('Testing').run(() async {
      testValue = 2;
    });

    final unexpectedRun2 = SingleInstanceTask.named('Testing').run(() async {
      testValue = 2;
    });

    final unexpectedRun3 = SingleInstanceTask.named('Testing').run(() async {
      testValue = 2;
    });

    await Future.wait([
      expectedRun,
      unexpectedRun1,
      unexpectedRun2,
      unexpectedRun3,
    ]);

    expect(testValue, 1);
  });

  test('Get the result of an executed task', () async {
    final expected = 'expected return value';

    final value =
        await SingleInstanceTask<String>.named('Testing').run(() async {
      Future.delayed(const Duration(seconds: 1));
      return expected;
    });

    expect(value, expected);
  });

  test('Get result when in-progress task completes', () async {
    final expected = 'expected return value';

    SingleInstanceTask<String>.named('Testing').run(() async {
      Future.delayed(const Duration(seconds: 1));
      return expected;
    });

    final value = await SingleInstanceTask<String>.named('Testing').run(
      () async => 'should not be returned',
    );

    expect(value, expected);
  });

  test('Get result when in-progress task completes', () async {
    final expected = 'expected return value';

    SingleInstanceTask<String>.named('Testing').run(() async {
      Future.delayed(const Duration(seconds: 1));
      return expected;
    });

    final value = await SingleInstanceTask<String>.named('Testing').run(
      () async => 'should not be returned',
    );

    expect(value, expected);
  });

  test('Create a task based on object alone', () async {
    final object = _DummyClass();

    final task1 = SingleInstanceTask.of(object);

    expect(task1.name, '_DummyClass');

    final task2 = SingleInstanceTask.of(object);

    expect(task1.name, task2.name);
  });

  test('A task throwing an exception does not prevent others', () async {
    var testValue = 0;

    try {
      await SingleInstanceTask.named('Testing').run(() async {
        throw Exception('Testing exceptions');
      });
    } on Exception {}

    await SingleInstanceTask.named('Testing').run(() async {
      testValue = 1;
    });

    expect(testValue, 1);
  });
}

class _DummyClass {}
