import 'package:equatable/equatable.dart';

class CallRecord extends Equatable {
  final String id;
  final Direction direction;
  final bool answered;
  final bool answeredElsewhere;
  final Duration duration;
  final DateTime date;
  final String callerName;
  final String callerNumber;
  final String destinationName;
  final String destinationNumber;

  const CallRecord({
    this.id,
    this.direction,
    this.answered,
    this.answeredElsewhere,
    this.duration,
    this.date,
    this.callerName,
    this.callerNumber,
    this.destinationName,
    this.destinationNumber,
  });

  bool get wasMissed => !answered;

  bool get isInbound => direction == Direction.inbound;

  bool get isOutbound => direction == Direction.outbound;

  @override
  String toString() {
    // TODO: Expand.
    return '$id';
  }

  CallRecord copyWith({
    String id,
    Direction direction,
    bool answered,
    bool answeredElsewhere,
    Duration duration,
    DateTime date,
    String callerName,
    String callerNumber,
    String destinationName,
    String destinationNumber,
  }) {
    return CallRecord(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      answered: answered ?? this.answered,
      answeredElsewhere: answeredElsewhere ?? this.answeredElsewhere,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      callerName: callerName ?? this.callerName,
      callerNumber: callerNumber ?? this.callerNumber,
      destinationName: destinationName ?? this.destinationName,
      destinationNumber: destinationNumber ?? this.destinationNumber,
    );
  }

  @override
  List<Object> get props => [id];
}

enum Direction {
  inbound,
  outbound,
}
