import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'unregister_to_voip_middleware.dart';

class LogoutUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _unregisterToVoipMiddleware = UnregisterToVoipMiddlewareUseCase();

  Future<void> call() async {
    await _unregisterToVoipMiddleware();

    await _clearStorage();
  }

  /// Clear the storage of all user-specific values.
  Future<void> _clearStorage() async {
    final remoteLoggingSetting =
        _storageRepository.settings.getOrNull<RemoteLoggingSetting>();

    final pushToken = _storageRepository.pushToken;

    await _storageRepository.clear();

    _storageRepository.pushToken = pushToken;

    // If the setting was null, it was not set yet, and we leave it like that.
    if (remoteLoggingSetting != null) {
      _storageRepository.settings = [
        remoteLoggingSetting,
      ];
    }
  }
}
