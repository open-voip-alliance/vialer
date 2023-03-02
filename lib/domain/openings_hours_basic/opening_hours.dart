import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'opening_hours.g.dart';

part 'opening_hours.freezed.dart';

@freezed
class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    String? id,
    String? name,
    @JsonKey(name: 'work_hours') List<WorkHours>? workHours,
    List<Holiday>? holidays,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

@freezed
class WorkHours with _$WorkHours {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WorkHours({
    required int dayOfWeek,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) TimeOfDay? timeStart,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) TimeOfDay? timeEnd,
  }) = _WorkHours;

  factory WorkHours.fromJson(Map<String, dynamic> json) =>
      _$WorkHoursFromJson(json);
}

TimeOfDay? _timeFromJson(String? time) => time == null
    ? null
    : TimeOfDay.fromDateTime(
        DateFormat('h:m:s').parse(time),
      );

String? _timeToJson(TimeOfDay? time) => time == null ? null : time.formatTime;

@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    required String id,
    required String country,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}

extension on TimeOfDay {
  String get formatTime {
    String addLeadingZeroIfNeeded(int value) {
      if (value < 10) {
        return '0$value';
      }
      return value.toString();
    }

    final hourLabel = addLeadingZeroIfNeeded(hour);
    final minuteLabel = addLeadingZeroIfNeeded(minute);

    return '$hourLabel:$minuteLabel:00';
  }
}
