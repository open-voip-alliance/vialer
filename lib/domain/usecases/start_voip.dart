import '../../dependency_locator.dart';
import '../entities/exceptions/voip_not_allowed.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_brand.dart';
import 'get_build_info.dart';
import 'get_is_voip_allowed.dart';
import 'get_voip_config.dart';
import 'register_to_voip_middleware.dart';

class StartVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _registerToMiddleware = RegisterToVoipMiddlewareUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();
  final _getBrand = GetBrandUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    if (!await _getIsVoipAllowed()) {
      throw VoipNotAllowedException();
    }

    await _voipRepository.initializeAndStart(
      config: await _getVoipConfig(latest: false),
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );

    await _registerToMiddleware();
  }
}
