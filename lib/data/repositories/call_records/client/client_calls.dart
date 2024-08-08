import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/data/API/voipgrid/voipgrid_service.dart';
import 'package:vialer/data/models/call_records/mappers/call_record.dart';
import 'package:vialer/data/repositories/legacy/storage.dart';

import '../../../../presentation/util/loggable.dart';
import '../../../models/call_records/call_record.dart';
import '../../../models/call_records/voipgrid_call_record.dart';
import '../../../models/calling/voip/destination.dart';

@singleton
class ClientCallsRepository with Loggable {
  ClientCallsRepository(
    this._voipgridService,
    this._storageRepository,
  );

  final VoipgridService _voipgridService;
  final StorageRepository _storageRepository;

  List<int> get _usersPhoneAccounts {
    final destinations = _storageRepository.availableDestinations;

    return destinations
        .whereType<PhoneAccount>()
        .map((phoneAccount) => phoneAccount.id)
        .toList();
  }

  Future<List<ClientCallRecord>> getCalls({
    required bool onlyMissedCalls,
    int page = 1,
  }) async {
    final response = await _voipgridService.getCalls(
      pageNumber: page,
      answered: onlyMissedCalls ? false : null,
    );

    final objects = response.body ?? const [];

    if (objects.isEmpty) return const [];

    var callRecords = objects.map(
      (dynamic json) => VoipgridCallRecord.fromJson(
        json as Map<String, dynamic>,
      ).toClientCallRecord(_usersPhoneAccounts),
    );

    // Restrict the missed calls only to incoming ones.
    if (onlyMissedCalls) {
      callRecords = callRecords.filter((contact) => contact.isInbound);
    }

    return callRecords.toList();
  }
}
