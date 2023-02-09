import 'package:dartx/dartx.dart';

/// Splits a date range into each individual month and returns each month as an
/// entry in a set.
class MonthSplitter {
  Map<DateTime, DateTime> split({
    required DateTime from,
    required DateTime to,
  }) {
    if (from.isAtSameMonthAs(to)) {
      return {from: to};
    }

    if (to.isBefore(from)) {
      throw ArgumentError(
        'to (${to.toIso8601String()}) must not be '
        'before from {${from.toIso8601String()}',
      );
    }

    final monthsToQuery = {
      from.firstDayOfMonth: from.endOfMonth,
    };

    var newDate = from.addMonth();

    while (!newDate.isAtSameMonthAs(to)) {
      monthsToQuery[newDate.firstDayOfMonth] = newDate.endOfMonth;
      newDate = newDate.addMonth();
    }

    monthsToQuery[to.firstDayOfMonth] = to.endOfMonth;

    return monthsToQuery;
  }
}

extension on DateTime {
  DateTime addMonth({int amount = 1}) => DateTime(
        year,
        month + amount,
        day,
        hour,
        minute,
        second,
      );

  DateTime get lastDayOfMonth => copyWith(
        day: daysInMonth,
        hour: 23,
        minute: 59,
        second: 59,
        microsecond: 999,
      );
}
