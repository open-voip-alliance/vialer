import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import 'voip.dart';

class GetIsVoipCallMutedUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<bool> call() => _voipRepository.isMuted;
}
