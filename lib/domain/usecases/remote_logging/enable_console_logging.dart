import 'dart:async';

import '../../../data/repositories/legacy/storage.dart';
import '../../../data/repositories/remote_logging/logging.dart';
import '../../../dependency_locator.dart';
import '../feedback/clear_saved_logs_on_new_day.dart';
import '../use_case.dart';
import '../user/get_stored_user.dart';

class EnableConsoleLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetStoredUserUseCase();
  final _clearSavedLogs = ClearSavedLogsOnNewDayUseCase();

  Future<void> call() async {
    unawaited(_clearSavedLogs());
    final user = _getUser();

    unawaited(_loggingRepository.enableNativeConsoleLogging());

    await _loggingRepository.enableConsoleLogging(
      userIdentifier: user?.loggingIdentifier ?? '',
      onLog: (log) async {
        if (_getUser() != null) {
          unawaited(_storageRepository.appendLogs(log));
        }
      },
    );
  }
}
