import '../../../dependency_locator.dart';
import '../../authentication/authentication_repository.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_build_info.dart';
import '../../user/get_latest_logged_in_user.dart';
import '../../user/get_logged_in_user.dart';
import '../../voipgrid/user_voip_config.dart';
import 'register_to_voip_middleware.dart';
import 'voip.dart';
import 'voip_not_allowed.dart';

class StartVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getUser = GetLoggedInUserUseCase();
  final _getLatestUser = GetLatestLoggedInUserUseCase();
  final _registerToMiddleware = RegisterToVoipMiddlewareUseCase();
  final _getBrand = GetBrand();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    if (!_getUser().voip.isAllowedCalling) {
      throw VoipNotAllowedException();
    }

    final config = await _fetchConfigAndConfigureAppAccount();

    await _voipRepository.initializeAndStart(
      userConfig: config,
      clientConfig: _getUser().client.voip,
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );

    await _registerToMiddleware();
  }

  /// Fetches the current voip config, configuring it as is required via the
  /// api and the latest config fetched from the server.
  Future<UserVoipConfig> _fetchConfigAndConfigureAppAccount() async {
    final config = _getUser().voip!;

    if (config.useOpus && config.useEncryption) return config;

    await _authRepository.updateAppAccount(
      useEncryption: true,
      useOpus: true,
    );

    return _getLatestUser().voip.then((v) => v!);
  }
}
