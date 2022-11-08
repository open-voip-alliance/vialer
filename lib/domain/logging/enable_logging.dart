import '../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_stored_user.dart';
import 'logging_repository.dart';

class EnableLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  final _getUser = GetStoredUserUseCase();

  Future<void> call() async {
    final user = await _getUser();

    _loggingRepository.enableNativeConsoleLogging();

    await _loggingRepository.enableConsoleLogging(
      userIdentifier: user?.loggingIdentifier ?? '',
    );

    await _loggingRepository.enableDatabaseLogging();
  }
}
