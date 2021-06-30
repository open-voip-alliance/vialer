import '../../domain/entities/call_record.dart';
import '../models/voipgrid_call_record.dart';

extension FromVoipgridCallRecord on VoipgridCallRecord {
  CallRecord toCallRecord() {
    return CallRecord(
      id: id,
      direction: _mapDirection(direction),
      answered: answered,
      answeredElsewhere: isAnsweredElsewhere,
      duration: Duration(seconds: durationInSeconds),
      date: startTime,
      callerName: _mapCallerName(from),
      callerNumber: from.phoneNumber,
      destinationName: _mapDestinationName(to),
      destinationNumber: to.phoneNumber,
    );
  }
}

Direction _mapDirection(String direction) =>
    direction == 'outgoing' ? Direction.outbound : Direction.inbound;

String? _mapCallerName(CallRecordFromDetail fromDetail) {
  if (fromDetail.callerName != null && fromDetail.callerName!.isNotEmpty) {
    return fromDetail.callerName;
  }

  if (fromDetail.voipAccount != null) {
    return fromDetail.voipAccount!.description;
  }

  return null;
}

String? _mapDestinationName(CallRecordToDetail toDetail) {
  if (toDetail.fixedDestination != null) {
    return toDetail.fixedDestination!.description;
  }

  if (toDetail.voipAccount != null) {
    return toDetail.voipAccount!.description;
  }

  return null;
}
