import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voipgrid_call_record.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VoipgridCallRecord extends Equatable {
  const VoipgridCallRecord({
    required this.id,
    required this.type,
    required this.answered,
    required this.isAnsweredElsewhere,
    required this.startTime,
    required this.direction,
    required this.durationInSeconds,
    required this.from,
    required this.to,
  });

  factory VoipgridCallRecord.fromJson(Map<String, dynamic> json) =>
      _$VoipgridCallRecordFromJson(json);
  final String id;
  final String type;
  final bool answered;
  final bool isAnsweredElsewhere;
  final DateTime startTime;
  final String direction;
  final int durationInSeconds;
  final CallRecordFromDetail from;
  final CallRecordToDetail to;

  @override
  List<Object> get props => [id];
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordFromDetail {
  const CallRecordFromDetail({
    required this.type,
    required this.phoneNumber,
    required this.dialedNumber,
    this.callerName,
    this.voipAccount,
  });

  factory CallRecordFromDetail.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFromDetailFromJson(json);
  final String type;
  final String phoneNumber;
  final String dialedNumber;
  final String? callerName;
  final CallRecordVoipAccount? voipAccount;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordToDetail {
  const CallRecordToDetail({
    required this.type,
    required this.phoneNumber,
    this.voipAccount,
    this.fixedDestination,
  });

  factory CallRecordToDetail.fromJson(Map<String, dynamic> json) =>
      _$CallRecordToDetailFromJson(json);
  final String type;
  final String phoneNumber;
  final CallRecordVoipAccount? voipAccount;
  final CallRecordFixedDestination? fixedDestination;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordVoipAccount {
  const CallRecordVoipAccount({
    required this.id,
    required this.internalNumber,
    this.description,
    this.outgoingName,
    this.outgoingNumber,
  });

  factory CallRecordVoipAccount.fromJson(Map<String, dynamic> json) =>
      _$CallRecordVoipAccountFromJson(json);
  final int id;
  final String? description;
  final String internalNumber;
  final String? outgoingName;
  final String? outgoingNumber;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordFixedDestination {
  const CallRecordFixedDestination({
    required this.id,
    required this.phoneNumber,
    this.description,
  });

  factory CallRecordFixedDestination.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFixedDestinationFromJson(json);
  final int id;
  final String? description;
  final String phoneNumber;
}
