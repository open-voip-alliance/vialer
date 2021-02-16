import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../use_case.dart';

class SendSavedLogsToRemoteUseCase extends FutureUseCase<void> {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  @override
  Future<void> call() => _loggingRepository.sendSavedLogsToRemote();
}
