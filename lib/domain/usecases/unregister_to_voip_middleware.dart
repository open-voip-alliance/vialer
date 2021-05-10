import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_is_voip_allowed.dart';
import 'get_voip_config.dart';

class UnregisterToVoipMiddlewareUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _getIsVoipAllowed = GetIsVoipAllowed();
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<void> call() async {
    // We only check if we're _allowed_ to use VoIP, not whether it's enabled,
    // because we unregister when VoIP is disabled.
    if (await _getIsVoipAllowed()) {
      await _voipRepository.unregister(await _getVoipConfig(latest: false));
    }
  }
}
