import '../../../../data/models/voipgrid/app_account.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

class UnregisterToMiddlewareUseCase extends UseCase {
  late final _voipRepository = dependencyLocator<VoipRepository>();
  late final _getUser = GetLoggedInUserUseCase();

  Future<void> call({AppAccount? appAccount}) async {
    final user = _getUser();

    if (appAccount != null || user.isAllowedVoipCalling) {
      await _voipRepository.unregister(appAccount ?? user.appAccount);
    }
  }
}
