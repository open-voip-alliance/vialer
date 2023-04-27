import '../../../../app/util/loggable.dart';
import '../../use_case.dart';
import 'import_client_call_records.dart';

class ImportHistoricClientCallRecordsUseCase extends UseCase with Loggable {
  final _importClientCalls = ImportClientCallsUseCase();

  /// The number of days of historic call records that we will import.
  static const _daysToImport = Duration(days: 90);

  Future<void> call() => _importClientCalls(
        from: DateTime.now().subtract(_daysToImport),
        to: DateTime.now().add(const Duration(days: 1)),
      );
}
