import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_current_app_account.dart';

class StartVoipUseCase extends FutureUseCase<void> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  final _getAppAccount = GetCurrentAppAccountUseCase();

  @override
  Future<void> call() async {
    await _voipRepository.start(await _getAppAccount());
  }
}
