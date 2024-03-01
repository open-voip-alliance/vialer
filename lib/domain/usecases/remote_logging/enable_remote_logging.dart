import '../../../data/repositories/remote_logging/logging.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_stored_user.dart';
import 'get_logging_token.dart';

class EnableRemoteLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  final _getUser = GetStoredUserUseCase();
  final _getLoggingToken = GetLoggingTokenUseCase();

  Future<void> call() async {
    final user = _getUser();

    final loggingIdentifier = user?.loggingIdentifier ?? '';

    if (_loggingRepository.isNativelyLoggingToRemote) {
      await _loggingRepository.disableNativeConsoleLogging();
    }

    final token = _getToken();

    if (_loggingRepository.isLoggingToRemote) {
      await _loggingRepository.disableRemoteLogging();
    }

    if (token == null) return;

    await _loggingRepository.enableNativeRemoteLogging(
      userIdentifier: loggingIdentifier,
      token: token,
    );

    return _loggingRepository.enableRemoteLogging(
      userIdentifier: loggingIdentifier,
      token: token,
    );
  }

  String? _getToken() {
    try {
      return _getLoggingToken();
    } catch (e) {
      return null;
    }
  }
}
