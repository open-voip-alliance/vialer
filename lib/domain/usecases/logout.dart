import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'unregister_to_voip_middleware.dart';

class LogoutUseCase extends FutureUseCase<void> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _unregisterToVoipMiddleware = UnregisterToVoipMiddlewareUseCase();

  @override
  Future<void> call() async {
    await _unregisterToVoipMiddleware();

    final remoteLoggingSetting =
        _storageRepository.settings.get<RemoteLoggingSetting>();

    await _storageRepository.clear();

    // If the setting was null, it was not set yet, and we leave it like that.
    if (remoteLoggingSetting != null) {
      _storageRepository.settings = [
        remoteLoggingSetting,
      ];
    }
  }
}
