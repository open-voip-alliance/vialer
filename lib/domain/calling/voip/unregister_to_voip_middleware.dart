import '../../../dependency_locator.dart';
import '../../use_case.dart';
import 'get_allowed_voip_config.dart';
import 'get_is_voip_allowed.dart';
import 'voip.dart';

class UnregisterToVoipMiddlewareUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _getNonEmptyVoipConfig = GetNonEmptyVoipConfigUseCase();

  Future<void> call() async {
    // We only check if we're _allowed_ to use VoIP, not whether it's enabled,
    // because we unregister when VoIP is disabled.
    if (await _getIsVoipAllowed()) {
      await _voipRepository.unregister(
        await _getNonEmptyVoipConfig(latest: false),
      );
    }
  }
}
