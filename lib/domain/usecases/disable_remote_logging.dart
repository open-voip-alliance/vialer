import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../use_case.dart';

class DisableRemoteLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  Future<void> call() => _loggingRepository.disableRemoteLogging();
}
