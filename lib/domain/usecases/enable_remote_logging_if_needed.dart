import '../../dependency_locator.dart';
import '../entities/settings/app_setting.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'enable_remote_logging.dart';
import 'get_stored_user.dart';

class EnableRemoteLoggingIfNeededUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetStoredUserUseCase();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();

  Future<void> call() async {
    final settings =
        _getUser()?.settings ?? _storageRepository.previousSessionSettings;

    final enabled = settings.getOrNull(AppSetting.remoteLogging) ?? false;

    if (enabled) {
      await _enableRemoteLogging();
    }
  }
}
