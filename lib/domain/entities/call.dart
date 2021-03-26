import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable(fieldRename: FieldRename.snake)
class Call extends Equatable {
  final String id;

  @JsonKey(fromJson: _directionFromJson)
  final Direction direction;
  final bool answered;

  @JsonKey(name: 'duration_in_seconds', fromJson: _durationFromJson)
  final Duration duration;

  @JsonKey(name: 'start_time')
  final Datetime date

  bool get wasMissed => !answered;

  bool get isInbound => direction == Direction.inbound;

  bool get isOutbound => direction == Direction.outbound;

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

Direction _directionFromJson(String json) {
  return json == 'outbound' ? Direction.outbound : Direction.inbound;
}

Duration _durationFromJson(String json) => Duration(seconds: json as int);




class XCall extends Equatable {
  static const _idKey = 'id';
  static const _dateKey = 'call_date';
  static const _durationKey = 'atime';
  static const _callerNumberKey = 'caller_num';
  static const _sourceNumberKey = 'src_number';
  static const _callerIdKey = 'callerid';
  static const _originalCallerIdKey = 'orig_callerid';
  static const _destinationNumberKey = 'dst_number';
  static const _directionKey = 'direction';

  final int id;

  /// Always UTC.
  final DateTime date;

  final Duration duration;

  final String callerNumber;
  final String sourceNumber;

  final String callerId;
  final String originalCallerId;

  final String destinationNumber;

  final Direction direction;

  bool get wasMissed =>
      direction == Direction.inbound && duration == Duration.zero;

  const Call({
    required this.id,
    required this.date,
    required this.duration,
    required this.callerNumber,
    required this.sourceNumber,
    required this.callerId,
    required this.originalCallerId,
    required this.destinationNumber,
    required this.direction,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json[_idKey] as int,
      date: DateTime.parse(json[_dateKey] as String),
      duration: Duration(seconds: json[_durationKey] as int),
      callerNumber: json[_callerNumberKey] as String,
      sourceNumber: json[_sourceNumberKey] as String,
      callerId: json[_callerIdKey] as String,
      originalCallerId: json[_originalCallerIdKey] as String,
      destinationNumber: json[_destinationNumberKey] as String,
      direction: _directionFromJson(json[_directionKey] as String),
    );
  }

  Call copyWith({
    int? id,
    DateTime? date,
    Duration? duration,
    String? callerNumber,
    String? sourceNumber,
    String? callerId,
    String? originalCallerId,
    String? destinationNumber,
    Direction? direction,
  }) {
    return Call(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      callerNumber: callerNumber ?? this.callerNumber,
      sourceNumber: sourceNumber ?? this.sourceNumber,
      callerId: callerId ?? this.callerId,
      originalCallerId: originalCallerId ?? this.originalCallerId,
      destinationNumber: destinationNumber ?? this.destinationNumber,
      direction: direction ?? this.direction,
    );
  }

  bool get isInbound => direction == Direction.inbound;

  bool get isOutbound => direction == Direction.outbound;

  @override
  String toString() {
    return '$id: $destinationNumber';
  }

  @override
  List<Object?> get props => [id];
}

enum Direction {
  inbound,
  outbound,
}

Direction _directionFromJson(String json) {
  return json == 'outbound' ? Direction.outbound : Direction.inbound;
}
