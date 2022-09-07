import 'package:dartx/dartx.dart';
import 'package:drift/drift.dart';
import 'package:flutter_phone_lib/call/call_direction.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

import '../../entities/call_record.dart';
import '../../entities/client_call_record.dart';
import '../database/client_calls.dart';
import '../remote_client_calls.dart';

extension FromDatabaseCallRecord on ClientCallDatabaseRecord {
  ClientCallRecord toCallRecord(
    ColleaguePhoneAccount? destinationAccount,
    ColleaguePhoneAccount? sourceAccount,
  ) =>
      ClientCallRecord(
        id: id.toString(),
        callType: callType,
        direction: direction,
        answered: answered,
        answeredElsewhere: direction == CallDirection.inbound &&
            destinationAccountId != null &&
            !isDestinationAccountLoggedInUser,
        duration: Duration(seconds: duration),
        date: date,
        caller: CallParty(
          name: sourceAccount?.callerIdName,
          number: sourceNumber,
          type: sourceAccount?.type ?? CallerType.other,
        ),
        destination: CallParty(
          name: destinationAccount?.callerIdName,
          number: destinationNumber.isNotNullOrEmpty
              ? destinationNumber
              : dialedNumber,
          type: destinationAccount?.type ?? CallerType.other,
        ),
        didTargetColleague:
            destinationAccountId != null && !isDestinationAccountLoggedInUser,
        didTargetLoggedInUser:
            destinationAccountId != null && isDestinationAccountLoggedInUser,
        wasInitiatedByColleague:
            sourceAccountId != null && !isSourceAccountLoggedInUser,
        wasInitiatedByLoggedInUser:
            sourceAccountId != null && isSourceAccountLoggedInUser,
      );
}

ClientCallsCompanion toClientCallDatabaseRecord(
  dynamic object, {
  required IsUserPhoneAccountLookup isUserPhoneAccount,
}) {
  final destinationAccountId = (object['dst_account'] as String?).extractedId;
  final sourceAccountId = (object['src_account'] as String?).extractedId;

  return ClientCallsCompanion.insert(
      id: Value(object['id'] as int),
      callType: destinationAccountId != null && sourceAccountId != null
          ? CallType.colleague
          : CallType.outside,
      direction: object['direction'] == 'outbound'
          ? Direction.outbound
          : Direction.inbound,
      answered: (object['atime'] as int) > 0,
      duration: object['atime'] as int,
      date: (object['call_date'] as String).toDateTimeFromVoipgridFormat,
      callerNumber: object['caller_num'] as String,
      sourceNumber: object['src_number'] as String,
      destinationNumber: object['dst_number'] as String,
      dialedNumber: object['dialed_number'] as String,
      callerId: object['callerid'] as String,
      originalCallerId: object['orig_callerid'] as String,
      destinationAccountId: Value(destinationAccountId),
      sourceAccountId: Value(sourceAccountId),
      isDestinationAccountLoggedInUser: destinationAccountId != null
          ? isUserPhoneAccount(destinationAccountId)
          : false,
      isSourceAccountLoggedInUser: sourceAccountId != null
          ? isUserPhoneAccount(sourceAccountId)
          : false);
}

/// This is the timezone that the VoIPGRID API operates in.
const _remoteClientCallTimezone = 'Europe/Amsterdam';

extension VoipgridFormat on DateTime {
  String get asVoipgridFormat => DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(
        TZDateTime.from(
          this,
          getLocation(_remoteClientCallTimezone),
        ),
      );
}

extension on String {
  DateTime get toDateTimeFromVoipgridFormat {
    final parsed = DateTime.parse(this);

    return TZDateTime(
      getLocation(_remoteClientCallTimezone),
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).toUtc();
  }
}

extension on String? {
  int? get extractedId {
    if (this == null) return null;

    try {
      final accountId = Uri.parse(this as String).pathSegments.lastOrNullWhere(
            (p) => p.isNotEmpty,
          );

      if (accountId == null || accountId.isEmpty) return null;

      return int.parse(accountId);
    } on Exception catch (_) {
      return null;
    }
  }
}
