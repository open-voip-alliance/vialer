import '../call_record.dart';
import '../voipgrid_call_record.dart';

extension FromVoipgridCallRecord on VoipgridCallRecord {
  CallRecord toCallRecord() {
    return CallRecordWithoutContact(
      id: id,
      callType: _mapCallType(type),
      callDirection: _mapDirection(direction),
      answered: answered,
      answeredElsewhere: isAnsweredElsewhere,
      duration: Duration(seconds: durationInSeconds),
      date: startTime,
      caller: _mapCaller(from),
      destination: _mapDestination(to),
    );
  }
}

CallType _mapCallType(String type) =>
    type == 'colleague_call' ? CallType.colleague : CallType.outside;

Direction _mapDirection(String direction) =>
    direction == 'outgoing' ? Direction.outbound : Direction.inbound;

CallParty _mapCaller(CallRecordFromDetail fromDetail) {
  String? name;
  late String number;

  if (fromDetail.voipAccount != null) {
    name = fromDetail.voipAccount!.description;
    number = fromDetail.voipAccount!.internalNumber;
  } else if (fromDetail.callerName?.isNotEmpty ?? false) {
    name = fromDetail.callerName;
    number = fromDetail.phoneNumber;
  } else {
    number = fromDetail.phoneNumber;
  }

  return CallParty(
    name: name,
    number: number,
    type: _mapCallerType(fromDetail.type),
  );
}

CallParty _mapDestination(CallRecordToDetail toDetail) {
  String? name;
  late String number;

  if (toDetail.voipAccount != null) {
    name = toDetail.voipAccount!.description;
    number = toDetail.voipAccount!.internalNumber;
  } else if (toDetail.fixedDestination != null) {
    name = toDetail.fixedDestination!.description;
    number = toDetail.fixedDestination!.phoneNumber;
  } else {
    number = toDetail.phoneNumber;
  }

  return CallParty(
    name: name,
    number: number,
    type: _mapCallerType(toDetail.type),
  );
}

CallerType _mapCallerType(String type) {
  switch (type) {
    case 'webphone':
      return CallerType.webphone;
    case 'app':
      return CallerType.app;
    case 'account':
      return CallerType.account;
    case 'other':
    default:
      return CallerType.other;
  }
}
