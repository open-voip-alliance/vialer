import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../use_case.dart';
import 'get_logging_token.dart';
import 'get_user.dart';

class EnableRemoteLoggingUseCase extends FutureUseCase<void> {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  final _getUser = GetUserUseCase();
  final _getLoggingToken = GetLoggingTokenUseCase();

  @override
  Future<void> call() async {
    await _loggingRepository.enableRemoteLogging(
      user: await _getUser(latest: false),
      token: await _getLoggingToken(),
    );
  }
}
