import 'package:dartx/dartx.dart';

import '../../../../data/repositories/call_records/client/local_client_calls.dart';
import '../../../../dependency_locator.dart';
import '../../../../presentation/util/loggable.dart';
import '../../use_case.dart';
import 'import_client_call_records.dart';

class ImportNewClientCallRecordsUseCase extends UseCase with Loggable {
  final _localClientCalls = dependencyLocator<LocalClientCallsRepository>();
  final _importClientCalls = ImportClientCallsUseCase();

  DateTime get fallbackStartTime => DateTime.now().firstDayOfMonth;

  Future<void> call() async {
    final mostRecentRecord = await _localClientCalls.mostRecent;

    // We will take the date of the most recent call record as our starting
    // point, applying some leeway around it to make sure we have all the
    // records.
    final start = mostRecentRecord?.date ?? fallbackStartTime;
    final now = DateTime.now();

    return _importClientCalls(
      from: start.toUtc().isBefore(now.toUtc()) ? start : fallbackStartTime,
      to: now,
    );
  }
}
