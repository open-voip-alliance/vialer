import '../../dependency_locator.dart';
import '../entities/exceptions/voip_not_enabled.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_brand.dart';
import 'get_build_info.dart';
import 'get_has_voip_enabled.dart';
import 'get_voip_config.dart';
import 'register_to_voip_middleware.dart';

class StartVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  final _getHasVoipEnabled = GetHasVoipEnabledUseCase();
  final _registerToMiddleware = RegisterToVoipMiddlewareUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();
  final _getBrand = GetBrandUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    if (!await _getHasVoipEnabled()) {
      throw VoipNotEnabledException();
    }

    await _voipRepository.start(
      config: await _getVoipConfig(latest: false),
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );
    await _registerToMiddleware();
  }
}
