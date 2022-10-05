import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'clear_saved_logs_on_new_day.dart';
import 'get_stored_user.dart';

class EnableConsoleLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetStoredUserUseCase();
  final _clearSavedLogs = ClearSavedLogsOnNewDayUseCase();

  Future<void> call() async {
    _clearSavedLogs();
    final user = await _getUser();

    _loggingRepository.enableNativeConsoleLogging();

    await _loggingRepository.enableConsoleLogging(
      userIdentifier: user?.loggingIdentifier ?? '',
      onLog: (log) async {
        if (_getUser() != null) {
          _storageRepository.appendLogs(log);
        }
      },
    );
  }
}
