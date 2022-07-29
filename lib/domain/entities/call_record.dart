import 'package:equatable/equatable.dart';

class CallRecord extends Equatable {
  final String id;
  final CallType callType;
  final Direction _direction;
  final bool answered;
  final bool answeredElsewhere;
  final Duration duration;
  final DateTime date;
  final CallParty caller;
  final CallParty destination;

  const CallRecord({
    required this.id,
    required this.callType,
    required Direction direction,
    required this.answered,
    required this.answeredElsewhere,
    required this.duration,
    required this.date,
    required this.caller,
    required this.destination,
  }) : _direction = direction;

  bool get wasMissed => !answered;

  Direction get direction => _isInboundForApp ? Direction.inbound : _direction;

  bool get isInbound => direction == Direction.inbound;

  bool get isOutbound => direction == Direction.outbound;

  String get thirdPartyNumber => isInbound ? caller.number : destination.number;

  String? get thirdPartyName => isInbound ? caller.name : destination.name;

  // When the call is between two VoIP accounts of the same user the
  // personalized API can't determine the direction of the call and it always
  // returns outbound. So override this specific case.
  bool get _isInboundForApp =>
      _direction == Direction.outbound &&
      _isColleagueCall &&
      destination.type == CallerType.app;

  bool get _isColleagueCall => callType == CallType.colleague;

  @override
  String toString() => '$id: ${destination.number}';

  CallRecord copyWith({
    String? id,
    CallType? callType,
    Direction? direction,
    bool? answered,
    bool? answeredElsewhere,
    Duration? duration,
    DateTime? date,
    CallParty? caller,
    CallParty? destination,
  }) {
    return CallRecord(
      id: id ?? this.id,
      callType: callType ?? this.callType,
      direction: direction ?? _direction,
      answered: answered ?? this.answered,
      answeredElsewhere: answeredElsewhere ?? this.answeredElsewhere,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      caller: caller ?? this.caller,
      destination: destination ?? this.destination,
    );
  }

  @override
  List<Object> get props => [id];
}

enum Direction {
  inbound,
  outbound,
}

enum CallType {
  colleague,
  outside,
}

enum CallerType {
  webphone,
  app,
  account,
  other,
}

class CallParty extends Equatable {
  final String? name;
  final String number;
  final CallerType type;

  const CallParty({
    this.name,
    required this.number,
    required this.type,
  });

  @override
  List<Object?> get props => [name, number, type];
}
