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

  test('Handles date ranges across year', () {
    // Using an actual date range that was causing issues
    final result = splitter.split(
      from: DateTime(2022, 12, 30, 15, 25, 16, 000),
      to: DateTime(
        2023,
        02,
        09,
        15,
        46,
        24,
        0,
        624181,
      ),
    );

    expect(result.length, 3);

    expect(
      result,
      {
        DateTime(2022, 12, 1): DateTime(2022, 12, 31, 23, 59, 59, 0, 999),
        DateTime(2023, 1, 1): DateTime(2023, 1, 31, 23, 59, 59, 0, 999),
        DateTime(2023, 2, 1): DateTime(2023, 2, 28, 23, 59, 59, 0, 624999),
      },
    );
  });
}
