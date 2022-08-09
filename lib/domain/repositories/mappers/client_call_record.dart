import 'package:dartx/dartx.dart';
import 'package:drift/drift.dart';
import 'package:flutter_phone_lib/call/call_direction.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

import '../../entities/call_record.dart';
import '../database/client_calls.dart';
import '../remote_client_calls.dart';

extension FromDatabaseCallRecord on ClientCallDatabaseRecord {
  CallRecord toCallRecord(
    ColleaguePhoneAccount? destinationAccount,
    ColleaguePhoneAccount? sourceAccount,
  ) =>
      CallRecord(
        id: id.toString(),
        callType: callType,
        direction: direction,
        answered: answered,
        answeredElsewhere: answeredElsewhere,
        duration: Duration(seconds: duration),
        date: date,
        caller: caller.name != null
            ? caller
            : CallParty(
                name: direction == CallDirection.outbound
                    ? sourceAccount?.callerIdName
                    : null,
                number: caller.number,
                type: sourceAccount?.type ?? CallerType.other,
              ),
        destination: answeredElsewhere && direction == Direction.inbound
            ? CallParty(
                name: destinationAccount?.callerIdName,
                number: destination.number,
                type: destinationAccount?.type ?? CallerType.other,
              )
            : destination,
        isClientCall: true,
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
    callType: _isInternalCall(object) ? CallType.colleague : CallType.outside,
    direction: object['direction'] == 'outbound'
        ? Direction.outbound
        : Direction.inbound,
    answered: (object['atime'] as int) > 0,
    answeredElsewhere: destinationAccountId != null
        ? !isUserPhoneAccount(destinationAccountId)
        : false,
    duration: object['atime'] as int,
    date: (object['call_date'] as String).toDateTimeFromVoipgridFormat,
    caller: CallParty(
      name: object['src_number'] as String,
      number: object['src_number'] as String,
      type: CallerType.other,
    ),
    destination: CallParty(
      name: null,
      number: object['dst_number'] as String,
      type: CallerType.other,
    ),
    destinationAccountId: Value(destinationAccountId),
    sourceAccountId: Value(sourceAccountId),
  );
}

/// This is the timezone that the VoIPGRID API operates in.
const _remoteClientCallTimezone = 'Europe/Amsterdam';

bool _isInternalCall(dynamic object) => const [
      'internal',
      'sip',
    ].contains(object['dst_code']);

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
