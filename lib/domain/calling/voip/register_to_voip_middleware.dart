import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import 'get_has_voip_enabled.dart';
import 'voip.dart';

class RegisterToVoipMiddlewareUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  final _getHasVoipEnabled = GetHasVoipEnabledUseCase();
  final _getUser = GetLoggedInUserUseCase();

  Future<void> call() async {
    if (await _getHasVoipEnabled()) {
      await _voipRepository.register(_getUser().voip);
    }
  }
}
