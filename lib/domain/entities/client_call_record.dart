import 'call_record.dart';

class ClientCallRecord extends CallRecord {
  final bool didTargetColleague;
  final bool didTargetLoggedInUser;
  final bool wasInitiatedByColleague;
  final bool wasInitiatedByLoggedInUser;

  const ClientCallRecord({
    required super.id,
    required super.callType,
    required super.direction,
    required super.answered,
    required super.answeredElsewhere,
    required super.duration,
    required super.date,
    required super.caller,
    required super.destination,
    required this.didTargetColleague,
    required this.didTargetLoggedInUser,
    required this.wasInitiatedByColleague,
    required this.wasInitiatedByLoggedInUser,
  });
}
