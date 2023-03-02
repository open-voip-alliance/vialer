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
    @JsonKey(name: 'work_hours') List<WorkingHours>? workingHours,
    List<Holiday>? holidays,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

@freezed
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

String? _timeToJson(TimeOfDay? time) => time != null ? time.formatTime : null;

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
    final hourLabel = hour.toString().padLeft(2, '0');
    final minuteLabel = minute.toString().padLeft(2, '0');

    return '$hourLabel:$minuteLabel:00';
  }
}
