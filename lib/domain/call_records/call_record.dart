import 'package:freezed_annotation/freezed_annotation.dart';

import '../colltacts/contact.dart';

part 'call_record.freezed.dart';
part 'call_record.g.dart';

@freezed
class CallRecord with _$CallRecord {
  const CallRecord._();

  const factory CallRecord.withoutContact({
    required String id,
    required CallType callType,
    required Direction callDirection,
    required bool answered,
    required bool answeredElsewhere,
    required Duration duration,
    required DateTime date,
    required CallParty caller,
    required CallParty destination,
  }) = CallRecordWithoutContact;

  /// CallRecord with a contact that relates to the [destinationNumber].
  const factory CallRecord.withContact({
    required String id,
    required CallType callType,
    required Direction callDirection,
    required bool answered,
    required bool answeredElsewhere,
    required Duration duration,
    required DateTime date,
    required CallParty caller,
    required CallParty destination,
    Contact? contact,
  }) = CallRecordWithContact;

  const factory CallRecord.client({
    required String id,
    required CallType callType,
    required Direction callDirection,
    required bool answered,
    required bool answeredElsewhere,
    required Duration duration,
    required DateTime date,
    required CallParty caller,
    required CallParty destination,
    required bool didTargetColleague,
    required bool didTargetLoggedInUser,
    required bool wasInitiatedByColleague,
    required bool wasInitiatedByLoggedInUser,
  }) = ClientCallRecord;

  bool get wasMissed => !answered;

  Direction get direction =>
      _isInboundForApp ? Direction.inbound : callDirection;

  bool get isInbound => direction == Direction.inbound;

  bool get isOutbound => direction == Direction.outbound;

  String get thirdPartyNumber => isInbound ? caller.number : destination.number;

  String? get thirdPartyName => isInbound ? caller.name : destination.name;

  // When the call is between two VoIP accounts of the same user the
  // personalized API can't determine the direction of the call and it always
  // returns outbound. So override this specific case.
  bool get _isInboundForApp =>
      callDirection == Direction.outbound &&
      _isColleagueCall &&
      destination.type == CallerType.app;

  bool get _isColleagueCall => callType == CallType.colleague;

  bool get isIncomingAndAnsweredElsewhere => answeredElsewhere && isInbound;

  @override
  String toString() => '$id: ${destination.number}';
}

extension WithContact on CallRecord {
  CallRecordWithContact withContact(Contact? contact) {
    return CallRecordWithContact(
      id: id,
      callType: callType,
      callDirection: callDirection,
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

@freezed
class CallParty with _$CallParty {
  const CallParty._();

  const factory CallParty({
    String? name,
    required String number,
    required CallerType type,
  }) = _CallParty;

  bool get hasName => name?.isNotEmpty == true;

  String get label => hasName ? name! : number;

  factory CallParty.fromJson(Map<String, dynamic> json) =>
      _$CallPartyFromJson(json);
}
