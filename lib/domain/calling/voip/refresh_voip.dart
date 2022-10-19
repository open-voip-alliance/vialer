import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'get_voip_config.dart';
import 'voip.dart';

class RefreshVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<void> call() async {
    await _voipRepository
        .refreshPreferences(await _getVoipConfig(latest: false));
  }
}
