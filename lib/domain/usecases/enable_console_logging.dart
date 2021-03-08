import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'clear_saved_logs_on_new_day.dart';
import 'get_user.dart';

class EnableConsoleLoggingUseCase extends FutureUseCase<void> {
  final _loggingRepository = dependencyLocator<LoggingRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetUserUseCase();
  final _clearSavedLogs = ClearSavedLogsOnNewDayUseCase();

  @override
  Future<void> call() async {
    _clearSavedLogs();

    await _loggingRepository.enableConsoleLogging(
      user: await _getUser(latest: false),
      onLog: _storageRepository.appendLogs,
    );
  }
}
