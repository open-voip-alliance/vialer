import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';

class GetIsVoipCallMutedUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<bool> call() => _voipRepository.isMuted;
}
