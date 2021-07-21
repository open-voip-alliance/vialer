import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'unregister_to_voip_middleware.dart';

class StopVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _unregisterToMiddleware = UnregisterToVoipMiddlewareUseCase();

  Future<void> call() async {
    await _voipRepository.stop();
    await _unregisterToMiddleware();
  }
}
