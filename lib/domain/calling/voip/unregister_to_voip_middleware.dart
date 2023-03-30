import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import 'voip.dart';

class UnregisterToVoipMiddlewareUseCase extends UseCase {
  late final _voipRepository = dependencyLocator<VoipRepository>();
  late final _getUser = GetLoggedInUserUseCase();

  Future<void> call() async {
    final user = _getUser();
    // We only check if we're _allowed_ to use VoIP, not whether it's enabled,
    // because we unregister when VoIP is disabled.
    await _voipRepository.unregister(user.voip);
  }
}
