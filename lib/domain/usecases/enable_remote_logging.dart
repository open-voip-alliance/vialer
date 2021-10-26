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
    final user = await _getUser(latest: false).then((u) => u!);
    final token = await _getLoggingToken();

    _loggingRepository.enableNativeRemoteLogging(
      userIdentifier: user.loggingIdentifier,
      token: token,
    );

    await _loggingRepository.enableRemoteLogging(
      userIdentifier: user.loggingIdentifier,
      token: token,
    );
  }
}
