import 'package:freezed_annotation/freezed_annotation.dart';

part 'voipgrid_call_record.g.dart';
part 'voipgrid_call_record.freezed.dart';

@freezed
class VoipgridCallRecord with _$VoipgridCallRecord {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VoipgridCallRecord({
    required String id,
    required String type,
    required bool answered,
    required bool isAnsweredElsewhere,
    required DateTime startTime,
    required String direction,
    required int durationInSeconds,
    required CallRecordFromDetail from,
    required CallRecordToDetail to,
  }) = _VoipgridCallRecord;

  factory VoipgridCallRecord.fromJson(Map<String, dynamic> json) =>
      _$VoipgridCallRecordFromJson(json);
}

@freezed
class CallRecordFromDetail with _$CallRecordFromDetail {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CallRecordFromDetail({
    required String type,
    required String phoneNumber,
    required String dialedNumber,
    String? callerName,
    CallRecordVoipAccount? voipAccount,
    String? userInternalNumber,
  }) = _CallRecordFromDetail;

  factory CallRecordFromDetail.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFromDetailFromJson(json);
}

@freezed
class CallRecordToDetail with _$CallRecordToDetail {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CallRecordToDetail({
    required String type,
    required String phoneNumber,
    CallRecordVoipAccount? voipAccount,
    CallRecordFixedDestination? fixedDestination,
  }) = _CallRecordToDetail;

  factory CallRecordToDetail.fromJson(Map<String, dynamic> json) =>
      _$CallRecordToDetailFromJson(json);
}

@freezed
class CallRecordVoipAccount with _$CallRecordVoipAccount {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CallRecordVoipAccount({
    required int id,
    String? description,
    required String internalNumber,
    String? outgoingName,
    String? outgoingNumber,
  }) = _CallRecordVoipAccount;

  factory CallRecordVoipAccount.fromJson(Map<String, dynamic> json) =>
      _$CallRecordVoipAccountFromJson(json);
}

@freezed
class CallRecordFixedDestination with _$CallRecordFixedDestination {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CallRecordFixedDestination({
    required int id,
    required String phoneNumber,
    String? description,
  }) = _CallRecordFixedDestination;

  factory CallRecordFixedDestination.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFixedDestinationFromJson(json);
}
