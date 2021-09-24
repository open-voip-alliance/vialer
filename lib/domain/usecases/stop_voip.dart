import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_is_voip_allowed.dart';
import 'get_voip_config.dart';
import 'unregister_to_voip_middleware.dart';

class StopVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _unregisterToMiddleware = UnregisterToVoipMiddlewareUseCase();
  final _isVoipAllowed = GetIsVoipAllowedUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<void> call() async {
    if (await _isVoipAllowed() &&
        (await _getVoipConfig(latest: false)).isNotEmpty) {
      await _voipRepository.stop();
      await _unregisterToMiddleware();
    }
  }
}
