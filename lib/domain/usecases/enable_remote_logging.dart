import '../../dependency_locator.dart';
import '../repositories/logging.dart';
import '../use_case.dart';
import 'get_user.dart';

class EnableRemoteLoggingUseCase extends FutureUseCase<void> {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  final _getUser = GetUserUseCase();

  @override
  Future<void> call() async {
    await _loggingRepository.enableRemoteLogging(
      user: await _getUser(latest: false),
    );
  }
}
