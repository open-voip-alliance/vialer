import '../../../dependency_locator.dart';
import '../../authentication/authentication_repository.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_build_info.dart';
import '../../voipgrid/voip_config.dart';
import 'get_allowed_voip_config.dart';
import 'get_is_voip_allowed.dart';
import 'register_to_voip_middleware.dart';
import 'voip.dart';
import 'voip_not_allowed.dart';

class StartVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _registerToMiddleware = RegisterToVoipMiddlewareUseCase();
  final _getNonEmptyVoipConfig = GetNonEmptyVoipConfigUseCase();
  final _getBrand = GetBrandUseCase();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    if (!await _getIsVoipAllowed()) {
      throw VoipNotAllowedException();
    }

    final config = await _fetchConfigAndConfigureAppAccount();

    await _voipRepository.initializeAndStart(
      config: config,
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );

    await _registerToMiddleware();
  }

  /// Fetches the current voip config, configuring it as is required via the
  /// api and the latest config fetched from the server.
  Future<NonEmptyVoipConfig> _fetchConfigAndConfigureAppAccount() async {
    final config = await _getNonEmptyVoipConfig(latest: false);

    if (config.useOpus && config.useEncryption) return config;

    await _authRepository.updateAppAccount(
      useEncryption: true,
      useOpus: true,
    );

    return _getNonEmptyVoipConfig(latest: true);
  }
}
