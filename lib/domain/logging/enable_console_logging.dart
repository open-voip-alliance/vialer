import '../../dependency_locator.dart';
import '../feedback/clear_saved_logs_on_new_day.dart';
import '../legacy/storage.dart';
import '../use_case.dart';
import '../user/get_stored_user.dart';
import 'logging_repository.dart';

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
