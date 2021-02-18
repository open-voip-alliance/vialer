import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'get_logging_token.dart';

class SendSavedLogsToRemoteUseCase extends FutureUseCase<void> {
  final _loggingRepository = dependencyLocator<LoggingRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getLoggingToken = GetLoggingTokenUseCase();

  @override
  Future<void> call() async {
    final logs = _storageRepository.logs;
    await _loggingRepository.sendLogsToRemote(
      logs,
      token: await _getLoggingToken(),
    );

    // Clear the logs after sending.
    _storageRepository.logs = null;
  }
}
