import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';

class GetIsVoipCallMutedUseCase extends FutureUseCase<bool> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Future<bool> call() => _voipRepository.isMuted;
}
