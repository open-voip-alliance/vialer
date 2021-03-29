import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/voip_config.dart';
import '../repositories/storage.dart';
import '../repositories/voip_config.dart';
import '../use_case.dart';

class GetVoipConfigUseCase extends FutureUseCase<VoipConfig> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _voipConfigRepository = dependencyLocator<VoipConfigRepository>();

  /// Gets the currently saved app account. If it's null or [latest]
  /// is true, it's fetched from the API.
  @override
  Future<VoipConfig> call({@required bool latest}) async {
    var voipConfig = _storageRepository.voipConfig;

    if (latest || voipConfig == null) {
      voipConfig = await _voipConfigRepository.get();
      _storageRepository.voipConfig = voipConfig;
    }

    return voipConfig;
  }
}
