import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../voipgrid/user_voip_config.dart';
import 'voip.dart';

class UnregisterToVoipMiddlewareUseCase extends UseCase {
  late final _voipRepository = dependencyLocator<VoipRepository>();
  late final _getUser = GetLoggedInUserUseCase();

  Future<void> call({UserVoipConfig? appAccount}) async {
    final user = _getUser();

    if (appAccount != null || user.isAllowedVoipCalling) {
      await _voipRepository.unregister(appAccount ?? user.voip);
    }
  }
}
