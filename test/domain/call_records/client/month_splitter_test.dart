import 'package:test/test.dart';
import 'package:vialer/domain/call_records/client/month_splitter.dart';

void main() {
  final splitter = MonthSplitter();

  test('Gives a single entry if the range is smaller than 1 month', () {
    final result =
        splitter.split(from: DateTime(2022, 11, 1), to: DateTime(2022, 11, 4));

    expect(result.length, 1);

    expect(
      result,
      {
        DateTime(2022, 11, 1): DateTime(2022, 11, 4),
      },
    );
  });

  test('Splits multiple months into individual entries', () {
    final result =
        splitter.split(from: DateTime(2022, 2, 1), to: DateTime(2022, 5, 4));

    expect(result.length, 4);

    expect(
      result,
      {
        DateTime(2022, 2, 1): DateTime(2022, 2, 28, 23, 59, 59, 0, 999),
        DateTime(2022, 3, 1): DateTime(2022, 3, 31, 23, 59, 59, 0, 999),
        DateTime(2022, 4, 1): DateTime(2022, 4, 30, 23, 59, 59, 0, 999),
        DateTime(2022, 5, 1): DateTime(2022, 5, 31, 23, 59, 59, 0, 999),
      },
    );
  });

  test('Throws an error if to is before from', () {
    expect(
      () => splitter.split(
        from: DateTime(2022, 8, 12),
        to: DateTime(2022, 5, 3),
      ),
      throwsA(const TypeMatcher<ArgumentError>()),
    );
  });
}
