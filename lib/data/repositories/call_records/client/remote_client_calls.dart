import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:dartx/dartx.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../presentation/util/loggable.dart';
import '../../../API/voipgrid/voipgrid_service.dart';
import '../../../models/call_records/call_record.dart';
import '../../../models/call_records/client/client_call_record.dart';
import '../../../models/call_records/client/database/client_calls.dart';
import 'local_client_calls.dart';

/// Allows a look-up to be performed as to whether the phone account being
/// is from the logged in user. This data is required when an object is built
/// so it is fetched via callback.
typedef IsUserPhoneAccountLookup = bool Function(int);

/// This repository is for interacting with the client calls API, this should
/// only be done when importing records into the database, it should not
/// be queried directly. For this reason and for performance/memory reasons
/// all methods return Drift Companion objects which can be directly insert
/// into the database.
///
/// Use [LocalClientCallsRepository] instead.
@singleton
class RemoteClientCallsRepository with Loggable {
  RemoteClientCallsRepository(this._service);

  final VoipgridService _service;

  /// The amount of records that we will be querying from the VoIPGRID API in
  /// each request.
  static const _chunkSize = 1000;

  /// The delay that will be added between each API requests to avoid rate
  /// limiting.
  static const _durationBetweenRequests = Duration(seconds: 2);

  /// The duration that we will wait after a failed request before retrying it
  /// once. This is to wait for any potential rate limits to be removed.
  static const _durationBeforeRetry = Duration(seconds: 10);

  /// Generator that will continually query the api and return batches
  /// of call records to be imported.
  ///
  /// The [from] and [to] date must be within the same month otherwise an
  /// exception will be thrown.
  Stream<List<ClientCallsCompanion>> fetchRecordsForDatabaseBetween({
    required DateTime from,
    required DateTime to,
    required IsUserPhoneAccountLookup isUserPhoneAccount,
    int offset = 0,
    bool retry = true,
  }) async* {
    if (!from.isAtSameMonthAs(to)) {
      throw ArgumentError(
        'It is only possible to fetch within the same month.',
      );
    }

    logger.info('Fetching client call records between $from and $to');

    final response = await _service.getClientCalls(
      limit: _chunkSize,
      offset: offset,
      from: from.asVoipgridFormat,
      to: to.asVoipgridFormat,
    );

    if (response.wasUnauthorized) {
      throw UserWasUnauthorized();
    }

    if (response.wasForbidden) {
      throw UserLacksCallRecordsPermission();
    }

    // If the response is not successful we will attempt a single retry.
    if (!response.isSuccessful && retry) {
      sleep(_durationBeforeRetry);
      yield* fetchRecordsForDatabaseBetween(
        from: from,
        to: to,
        retry: false,
        isUserPhoneAccount: isUserPhoneAccount,
      );
      return;
    }

    final objects = await response.body!['objects'] as List<dynamic>;

    logger.info('Fetched ${objects.length} call records from the api');

    yield objects
        .map(
          (dynamic item) => toClientCallDatabaseRecord(
            item as Map<String, dynamic>,
            isUserPhoneAccount: isUserPhoneAccount,
          ),
        )
        .toList();

    if (response.hasMoreRecords) {
      sleep(_durationBetweenRequests);
      yield* fetchRecordsForDatabaseBetween(
        from: from,
        to: to,
        offset: offset + _chunkSize,
        isUserPhoneAccount: isUserPhoneAccount,
      );
    }
  }

  Future<ColleaguePhoneAccountsCompanion?> fetchPhoneAccount(int id) async {
    final response = await _service.getPhoneAccount(id.toString());

    logger.info('Fetching phone account: $id');

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch Phone Account');
      return null;
    }

    final object = response.body!;

    return ColleaguePhoneAccountsCompanion.insert(
      id: Value(id),
      callerIdName: object['callerid_name'] as String,
      country: object['country'] as String,
      description: object['description'] as String,
      internalNumber: (object['internal_number'] as int).toString(),
      type: _findPhoneAccountType(object),
      fetchedAt: DateTime.now(),
    );
  }
}

extension on Response<Map<String, dynamic>> {
  bool get hasMoreRecords {
    final next =
        (this.body?['meta'] as Map<String, dynamic>)['next'] as String?;

    return next != null && next.isNotEmpty;
  }

  bool get wasForbidden => statusCode == 403;

  bool get wasUnauthorized => statusCode == 401;
}

class UserLacksCallRecordsPermission implements Exception {}

class UserWasUnauthorized implements Exception {}

CallerType _findPhoneAccountType(Map<String, dynamic> object) {
  if (object['is_app_account'] as bool) return CallerType.app;
  if (object['is_desktop_account'] as bool) return CallerType.webphone;

  return CallerType.other;
}
