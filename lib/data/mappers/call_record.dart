import '../../domain/entities/call_record.dart';
import '../../domain/repositories/db/database.dart';
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

extension ToDbCallRecord on CallRecord {
  DbCallRecord toDbCallRecord() {
    return DbCallRecord(
      id: id,
      direction: direction,
      answered: answered,
      answeredElsewhere: answeredElsewhere,
      duration: duration,
      date: date,
      callerName: callerName,
      callerNumber: callerNumber,
      destinationName: destinationName,
      destinationNumber: destinationNumber,
    );
  }
}

extension FromDbCallRecord on DbCallRecord {
  CallRecord toCallRecord() {
    return CallRecord(
      id: id,
      direction: direction,
      answered: answered,
      answeredElsewhere: answeredElsewhere,
      duration: duration,
      date: date,
      callerName: callerName,
      callerNumber: callerNumber,
      destinationName: destinationName,
      destinationNumber: destinationNumber,
    );
  }
}

Direction _mapDirection(String direction) =>
    direction == 'outgoing' ? Direction.outbound : Direction.inbound;

String _mapCallerName(CallRecordFromDetail fromDetail) {
  if (fromDetail.callerName.isNotEmpty) {
    return fromDetail.callerName;
  }

  if (fromDetail.voipAccount != null) {
    return fromDetail.voipAccount.description;
  }

  return null;
}

String _mapDestinationName(CallRecordToDetail toDetail) {
  if (toDetail.fixedDestination != null) {
    return toDetail.fixedDestination.description;
  }

  if (toDetail.voipAccount != null) {
    return toDetail.voipAccount.description;
  }

  return null;
}
