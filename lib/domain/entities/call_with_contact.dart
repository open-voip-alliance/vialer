import 'call.dart';
import 'contact.dart';

class CallWithContact extends Call {
  /// Contact that relates to the [destinationNumber].
  final Contact? contact;

  const CallWithContact({
    required int id,
    required DateTime date,
    required Duration duration,
    required String callerNumber,
    required String sourceNumber,
    required String callerId,
    required String originalCallerId,
    required String destinationNumber,
    required Direction direction,
    this.contact,
  }) : super(
          id: id,
          date: date,
          duration: duration,
          callerNumber: callerNumber,
          sourceNumber: sourceNumber,
          callerId: callerId,
          originalCallerId: originalCallerId,
          destinationNumber: destinationNumber,
          direction: direction,
        );

  @override
  CallWithContact copyWith({
    int? id,
    DateTime? date,
    Duration? duration,
    String? callerNumber,
    String? sourceNumber,
    String? callerId,
    String? originalCallerId,
    String? destinationNumber,
    Direction? direction,
    Contact? contact,
  }) {
    return CallWithContact(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      callerNumber: callerNumber ?? this.callerNumber,
      sourceNumber: sourceNumber ?? this.sourceNumber,
      callerId: callerId ?? this.callerId,
      originalCallerId: originalCallerId ?? this.originalCallerId,
      destinationNumber: destinationNumber ?? this.destinationNumber,
      direction: direction ?? this.direction,
      contact: contact ?? this.contact,
    );
  }
}

extension WithContact on Call {
  CallWithContact withContact(Contact? contact) {
    return CallWithContact(
      id: id,
      date: date,
      duration: duration,
      callerNumber: callerNumber,
      sourceNumber: sourceNumber,
      callerId: callerId,
      originalCallerId: originalCallerId,
      destinationNumber: destinationNumber,
      direction: direction,
      contact: contact,
    );
  }
}
