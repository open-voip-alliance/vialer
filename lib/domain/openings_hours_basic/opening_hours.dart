<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
=======
import 'package:freezed_annotation/freezed_annotation.dart';
>>>>>>> 7e22bf86 (fetch time tables)

part 'opening_hours.g.dart';

part 'opening_hours.freezed.dart';

@freezed
class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    String? id,
<<<<<<< HEAD
    required String name,
    @JsonKey(name: 'work_hours') @Default([]) List<WorkingHours> workingHours,
    @Default([]) List<Holiday> holidays,
=======
    String? name,
    List<WorkHours>? workHours,
    List<Holiday>? holidays,
>>>>>>> 7e22bf86 (fetch time tables)
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

@freezed
<<<<<<< HEAD
class WorkingHours with _$WorkingHours {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WorkingHours({
    required int dayOfWeek,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) TimeOfDay? timeStart,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) TimeOfDay? timeEnd,
  }) = _WorkingHours;

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);
}

TimeOfDay? _timeFromJson(String? time) => time != null
    ? TimeOfDay.fromDateTime(
        DateFormat('h:m:s').parse(time),
      )
    : null;

String? _timeToJson(TimeOfDay? time) =>
    time != null ? time.formattedTime : null;
=======
class WorkHours with _$WorkHours {
  const factory WorkHours({
    required int dayOfWeek,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime timeStart,
    @JsonKey(fromJson: _dateTimeFromJson) DateTime? timeEnd,
  }) = _WorkHours;

  factory WorkHours.fromJson(Map<String, dynamic> json) =>
      _$WorkHoursFromJson(json);
}

DateTime _dateTimeFromJson(String datetime) => DateTime.parse(datetime);
>>>>>>> 7e22bf86 (fetch time tables)

@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    required String id,
    required String country,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}
<<<<<<< HEAD

extension on TimeOfDay {
  String get formattedTime {
    final hourLabel = hour.toString().padLeft(2, '0');
    final minuteLabel = minute.toString().padLeft(2, '0');

    return '$hourLabel:$minuteLabel:00';
  }
}
=======
>>>>>>> 7e22bf86 (fetch time tables)
