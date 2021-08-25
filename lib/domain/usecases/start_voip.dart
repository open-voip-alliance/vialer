import '../../dependency_locator.dart';
import '../entities/exceptions/voip_not_allowed.dart';
import '../entities/voip_config.dart';
import '../repositories/auth.dart';
import '../repositories/voip.dart';
import '../use_case.dart';
import 'get_brand.dart';
import 'get_build_info.dart';
import 'get_is_voip_allowed.dart';
import 'get_voip_config.dart';
import 'register_to_voip_middleware.dart';

class StartVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _registerToMiddleware = RegisterToVoipMiddlewareUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();
  final _getBrand = GetBrandUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    if (!await _getIsVoipAllowed()) {
      throw VoipNotAllowedException();
    }

    final config = await _fetchConfigAndEnableOpus();

    await _voipRepository.initializeAndStart(
      config: config,
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );

    await _registerToMiddleware();
  }

  /// Fetches the current voip config, if OPUS is not enabled, it will be
  /// enabled and the latest config fetched from the server.
  Future<VoipConfig> _fetchConfigAndEnableOpus() async {
    final config = await _getVoipConfig(latest: false);

    if (config.useOpus) return config;

    await _authRepository.enableOpus();
    return _getVoipConfig(latest: true);
  }
}
