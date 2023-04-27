import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'opening_hours.g.dart';

part 'opening_hours.freezed.dart';

@freezed
class OpeningHoursModule with _$OpeningHoursModule {
  const factory OpeningHoursModule({
    required String id,
    required String name,
    @JsonKey(name: 'work_hours')
    @Default(<OpeningHours>[])
        List<OpeningHours> openingHours,
    @Default(<Holiday>[]) List<Holiday> holidays,
  }) = _OpeningHoursModule;

  factory OpeningHoursModule.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursModuleFromJson(json);
}

@freezed
class OpeningHours with _$OpeningHours {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OpeningHours({
    required int dayOfWeek,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) TimeOfDay? timeStart,
    @JsonKey(fromJson: _timeFromJson, toJson: _timeToJson) TimeOfDay? timeEnd,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

TimeOfDay? _timeFromJson(String? time) => time != null
    ? TimeOfDay.fromDateTime(
        DateFormat('h:m:s').parse(time),
      )
    : null;

String? _timeToJson(TimeOfDay? time) => time?.formattedTime;

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
  String get formattedTime {
    final hourLabel = hour.toString().padLeft(2, '0');
    final minuteLabel = minute.toString().padLeft(2, '0');

    return '$hourLabel:$minuteLabel:00';
  }
}
