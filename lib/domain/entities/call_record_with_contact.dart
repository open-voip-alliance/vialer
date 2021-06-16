import 'call_record.dart';
import 'contact.dart';

class CallRecordWithContact extends CallRecord {
  /// Contact that relates to the [destinationNumber].
  final Contact? contact;

  const CallRecordWithContact({
    required String id,
    required Direction direction,
    required bool answered,
    required bool answeredElsewhere,
    required Duration duration,
    required DateTime date,
    String? callerName,
    required String callerNumber,
    String? destinationName,
    required String destinationNumber,
    this.contact,
  }) : super(
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

  @override
  CallRecordWithContact copyWith({
    String? id,
    Direction? direction,
    bool? answered,
    bool? answeredElsewhere,
    Duration? duration,
    DateTime? date,
    String? callerName,
    String? callerNumber,
    String? destinationName,
    String? destinationNumber,
    Contact? contact,
  }) {
    return CallRecordWithContact(
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
      contact: contact ?? this.contact,
    );
  }
}

extension WithContact on CallRecord {
  CallRecordWithContact withContact(Contact? contact) {
    return CallRecordWithContact(
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
      contact: contact,
    );
  }
}
