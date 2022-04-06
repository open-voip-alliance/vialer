import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'get_logging_token.dart';
import 'get_user.dart';

class SendSavedLogsToRemoteUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getLoggingToken = GetLoggingTokenUseCase();
  final _getUser = GetUserUseCase();

  Future<void> call() async {
    await _storageRepository.reload();
    final logs = _storageRepository.logs;
    final user = await _getUser(latest: false);

    if (logs != null && logs.isNotEmpty && user != null) {
      /// Prepending the log with a note to specify that this was a saved log
      /// (to account for the time difference in uploading) and adding the
      /// user id so they are searchable even if there was no user id at the
      /// time they were logged (i.e. during onboarding).
      final saved = '(saved log from ${user.loggingIdentifier})';

      final formattedLogs = logs
          .split('\n')
          .where((line) => line.isNotEmpty)
          .map((line) => '$saved $line')
          .join('\n');

      await _loggingRepository.sendLogsToRemote(
        formattedLogs,
        token: await _getLoggingToken(),
      );

      // Clear the logs after sending.
      _storageRepository.logs = null;
    }
  }
}
