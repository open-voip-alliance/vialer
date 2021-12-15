import 'dart:core';

import 'package:dartx/dartx.dart';

import '../../dependency_locator.dart';
import '../entities/call_record.dart';
import '../entities/call_record_with_contact.dart';
import '../entities/contact.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';
import 'get_contact.dart';
import 'get_user.dart';

class GetRecentCallsUseCase extends UseCase {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();

  final _getUser = GetUserUseCase();
  final _getContact = GetContactUseCase();

  /// [page] starts at 1.
  Future<List<CallRecordWithContact>> call({
    required int page,
    bool onlyMissedCalls = false,
  }) async {
    assert(page > 0);
    final user = await _getUser(latest: false);

    final callRecords = await _recentCallRepository.getRecentCalls(
      page: page,
      outgoingNumber: user!.outgoingCli!,
      onlyMissedCalls: onlyMissedCalls,
    );

    return populateWithContacts(callRecords);
  }

  Future<List<CallRecordWithContact>> populateWithContacts(
    List<CallRecord> callRecords,
  ) async {
    final foundContacts = <String, Contact>{};

    final uniqueNumbers =
        callRecords.map((e) => e.numberForContactLookup).distinct();

    for (var number in uniqueNumbers) {
      final contact = await _getContact(number: number);

      if (contact != null) {
        foundContacts[number] = contact;
      }
    }

    return callRecords
        .map(
          (call) => call.withContact(
            foundContacts[call.numberForContactLookup],
          ),
        )
        .toList();
  }
}

extension on CallRecord {
  String get numberForContactLookup =>
      isOutbound ? destination.number : caller.number;
}
