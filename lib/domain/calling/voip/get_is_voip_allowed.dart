import '../../use_case.dart';
import 'get_voip_config.dart';

class GetIsVoipAllowedUseCase extends UseCase {
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<bool> call() =>
      _getVoipConfig(latest: false).then((c) => c.isAllowedCalling);
}
