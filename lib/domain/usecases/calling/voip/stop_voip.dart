import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import 'unregister_to_middleware.dart';

class StopVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _unregisterToMiddleware = UnregisterToMiddlewareUseCase();

  Future<void> call() async {
    await _voipRepository.close();
    await _unregisterToMiddleware();
  }
}
