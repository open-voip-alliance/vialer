import '../contacts/contact.dart';
import 'call_record.dart';

class CallRecordWithContact extends CallRecord {
  /// Contact that relates to the [destinationNumber].
  final Contact? contact;

  CallRecordWithContact({
    required String id,
    required CallType callType,
    required Direction direction,
    required bool answered,
    required bool answeredElsewhere,
    required Duration duration,
    required DateTime date,
    required CallParty caller,
    required CallParty destination,
    this.contact,
  }) : super(
          id: id,
          callType: callType,
          direction: direction,
          answered: answered,
          answeredElsewhere: answeredElsewhere,
          duration: duration,
          date: date,
          caller: caller,
          destination: destination,
        );

  @override
  CallRecordWithContact copyWith({
    String? id,
    CallType? callType,
    Direction? direction,
    bool? answered,
    bool? answeredElsewhere,
    Duration? duration,
    DateTime? date,
    String? callerName,
    String? callerNumber,
    CallParty? caller,
    CallParty? destination,
    Contact? contact,
  }) {
    return CallRecordWithContact(
      id: id ?? this.id,
      callType: callType ?? this.callType,
      direction: direction ?? this.direction,
      answered: answered ?? this.answered,
      answeredElsewhere: answeredElsewhere ?? this.answeredElsewhere,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      caller: caller ?? this.caller,
      destination: destination ?? this.destination,
      contact: contact ?? this.contact,
    );
  }
}

extension WithContact on CallRecord {
  CallRecordWithContact withContact(Contact? contact) {
    return CallRecordWithContact(
      id: id,
      callType: callType,
      direction: direction,
      answered: answered,
      answeredElsewhere: answeredElsewhere,
      duration: duration,
      date: date,
      caller: caller,
      destination: destination,
      contact: contact,
    );
  }
}
