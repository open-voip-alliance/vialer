import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_allowed_voip_config.dart';
import 'get_has_voip_enabled.dart';

class RegisterToVoipMiddlewareUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  final _getHasVoipEnabled = GetHasVoipEnabledUseCase();
  final _getNonEmptyVoipConfig = GetNonEmptyVoipConfigUseCase();

  Future<void> call() async {
    if (await _getHasVoipEnabled()) {
      await _voipRepository.register(
        await _getNonEmptyVoipConfig(latest: false),
      );
    }
  }
}
