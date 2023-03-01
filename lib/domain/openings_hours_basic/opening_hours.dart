import 'package:freezed_annotation/freezed_annotation.dart';

part 'opening_hours.g.dart';

part 'opening_hours.freezed.dart';

@freezed
class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    String? id,
    String? name,
    List<WorkHours>? workHours,
    List<Holiday>? holidays,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
}

@freezed
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

@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    required String id,
    required String country,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}
