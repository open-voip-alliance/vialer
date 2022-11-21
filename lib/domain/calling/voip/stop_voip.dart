import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../voipgrid/user_voip_config.dart';
import 'unregister_to_voip_middleware.dart';
import 'voip.dart';

class StopVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _unregisterToMiddleware = UnregisterToVoipMiddlewareUseCase();
  final _getUser = GetLoggedInUserUseCase();

  Future<void> call() async {
    if (_getUser().voip.isAllowedCalling) {
      await _voipRepository.close();
      await _unregisterToMiddleware();
    }
  }
}
