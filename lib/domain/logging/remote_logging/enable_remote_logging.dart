import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_stored_user.dart';
import '../logging_repository.dart';

class EnableRemoteLoggingUseCase extends UseCase {
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  final _getUser = GetStoredUserUseCase();
  //final _getLoggingToken = GetLoggingTokenUseCase();

  Future<void> call() async {
    final user = _getUser();
    // TODO: Get rid of logging token
    //final token = await _getLoggingToken();

    final loggingIdentifier = user?.loggingIdentifier ?? '';

    return _loggingRepository.enableDatabaseLogging(
      userIdentifier: loggingIdentifier,
    );
  }
}
