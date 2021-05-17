import '../../dependency_locator.dart';
import '../entities/voip_config.dart';
import '../repositories/storage.dart';
import '../repositories/voip_config.dart';
import '../use_case.dart';

class GetLatestVoipConfigUseCase extends UseCase {
  final _voipConfigRepository = dependencyLocator<VoipConfigRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<VoipConfig> call() async {
    final voipConfig = await _voipConfigRepository.get();

    _storageRepository.voipConfig = voipConfig;

    return voipConfig;
  }
}
