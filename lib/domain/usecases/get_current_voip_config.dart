import '../../dependency_locator.dart';
import '../entities/voip_config.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'get_latest_voip_config.dart';

class GetCurrentVoipConfigUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _getLatestVoipConfig = GetLatestVoipConfigUseCase();

  /// Gets the currently saved app account. If it's null, it's fetched
  /// from the API.
  Future<VoipConfig> call() async {
    var voipConfig = _storageRepository.voipConfig;

    if (voipConfig == null) {
      voipConfig = await _getLatestVoipConfig();
    }

    return voipConfig;
  }
}
