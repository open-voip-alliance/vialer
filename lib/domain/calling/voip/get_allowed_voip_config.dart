import '../../use_case.dart';
import '../../voipgrid/voip_config.dart';
import 'get_voip_config.dart';

class GetNonEmptyVoipConfigUseCase extends UseCase {
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<NonEmptyVoipConfig> call({required bool latest}) =>
      _getVoipConfig(latest: latest).then((c) => c as NonEmptyVoipConfig);
}
