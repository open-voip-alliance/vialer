import '../../../data/repositories/remote_logging/logging.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class DisableRemoteLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  Future<void> call() => _loggingRepository
      .disableRemoteLogging()
      .then((_) => _loggingRepository.disableNativeRemoteLogging());
}
