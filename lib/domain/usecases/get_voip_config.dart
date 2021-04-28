import '../../dependency_locator.dart';
import '../entities/voip_config.dart';
import '../repositories/storage.dart';
import '../repositories/voip_config.dart';
import '../use_case.dart';

class GetVoipConfigUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _voipConfigRepository = dependencyLocator<VoipConfigRepository>();

  /// Gets the currently saved app account. If it's null or [latest]
  /// is true, it's fetched from the API.
  Future<VoipConfig> call({required bool latest}) async {
    // The StorageRepository is reloaded, because the VoipConfig could've been
    // changed in the foreground or background, something that's not reflected
    // in the cache since the change happened in a different isolate.
    await _storageRepository.reload();
    var voipConfig = _storageRepository.voipConfig;

    if (latest || voipConfig == null) {
      voipConfig = await _voipConfigRepository.get();
      _storageRepository.voipConfig = voipConfig;
    }

    return voipConfig;
  }
}
