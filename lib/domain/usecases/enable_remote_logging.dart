import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../use_case.dart';
import 'get_logging_token.dart';
import 'get_user.dart';

class EnableRemoteLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  final _getUser = GetUserUseCase();
  final _getLoggingToken = GetLoggingTokenUseCase();

  Future<void> call() async {
    final user = await _getUser(latest: false);
    final token = await _getLoggingToken();

    final loggingIdentifier = user?.loggingIdentifier ?? '';

    if (_loggingRepository.isNativelyLoggingToRemote) {
      await _loggingRepository.disableNativeConsoleLogging();
    }

    await _loggingRepository.enableNativeRemoteLogging(
      userIdentifier: loggingIdentifier,
      token: token,
    );

    if (_loggingRepository.isLoggingToRemote) {
      await _loggingRepository.disableRemoteLogging();
    }

    await _loggingRepository.enableRemoteLogging(
      userIdentifier: loggingIdentifier,
      token: token,
    );
  }
}
