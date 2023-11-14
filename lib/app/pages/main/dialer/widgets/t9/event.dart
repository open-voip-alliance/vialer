import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';

@freezed
sealed class T9ColltactsEvent with _$T9ColltactsEvent {
  const factory T9ColltactsEvent.load() = LoadColltacts;
  const factory T9ColltactsEvent.filter(String input) = FilterT9Colltacts;
}
