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
    await _loggingRepository.enableRemoteLogging(
      user: await _getUser(latest: false).then((u) => u!),
      token: await _getLoggingToken(),
    );
  }
}
