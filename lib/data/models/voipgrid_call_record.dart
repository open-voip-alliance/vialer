import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'voipgrid_call_record.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VoipgridCallRecord extends Equatable {
  final String id;
  final String type;
  final bool answered;
  final bool isAnsweredElsewhere;
  final DateTime startTime;
  final String direction;
  final int durationInSeconds;
  final CallRecordFromDetail from;
  final CallRecordToDetail to;

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

  @override
  List<Object> get props => [id];

  factory VoipgridCallRecord.fromJson(Map<String, dynamic> json) =>
      _$VoipgridCallRecordFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordFromDetail {
  final String type;
  final String phoneNumber;
  final String dialedNumber;
  final String? callerName;
  final CallRecordVoipAccount? voipAccount;

  const CallRecordFromDetail({
    required this.type,
    required this.phoneNumber,
    required this.dialedNumber,
    this.callerName,
    this.voipAccount,
  });

  factory CallRecordFromDetail.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFromDetailFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordToDetail {
  final String type;
  final String phoneNumber;
  final CallRecordVoipAccount? voipAccount;
  final CallRecordFixedDestination? fixedDestination;

  const CallRecordToDetail({
    required this.type,
    required this.phoneNumber,
    this.voipAccount,
    this.fixedDestination,
  });

  factory CallRecordToDetail.fromJson(Map<String, dynamic> json) =>
      _$CallRecordToDetailFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordVoipAccount {
  final int id;
  final String? description;
  final String internalNumber;
  final String? outgoingName;
  final String outgoingNumber;

  const CallRecordVoipAccount({
    required this.id,
    this.description,
    required this.internalNumber,
    this.outgoingName,
    required this.outgoingNumber,
  });

  factory CallRecordVoipAccount.fromJson(Map<String, dynamic> json) =>
      _$CallRecordVoipAccountFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CallRecordFixedDestination {
  final int id;
  final String? description;
  final String phoneNumber;

  const CallRecordFixedDestination({
    required this.id,
    this.description,
    required this.phoneNumber,
  });

  factory CallRecordFixedDestination.fromJson(Map<String, dynamic> json) =>
      _$CallRecordFixedDestinationFromJson(json);
}
