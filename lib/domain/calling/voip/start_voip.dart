import '../../../dependency_locator.dart';
import '../../authentication/authentication_repository.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_build_info.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/user.dart';
import '../../voipgrid/user_voip_config.dart';
import 'register_to_voip_middleware.dart';
import 'voip.dart';
import 'voip_not_allowed.dart';

class StartVoipUseCase extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getUser = GetLoggedInUserUseCase();
  final _registerToMiddleware = RegisterToVoipMiddlewareUseCase();
  final _getBrand = GetBrand();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    final user = _getUser();

    if (!user.voip.isAllowedCalling) {
      throw VoipNotAllowedException();
    }

    await _updateVoipConfig(user.voip!);

    await _voipRepository.initializeAndStart(
      user: user,
      clientConfig: user.client.voip,
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );

    await _registerToMiddleware();
  }



  /// Update the VoIP config with the correct values if necessary.
  Future<void> _updateVoipConfig(UserVoipConfig config) async {
    if (config.useOpus && config.useEncryption) return;

    await _authRepository.updateAppAccount(
      useEncryption: true,
      useOpus: true,
    );
  }

}
