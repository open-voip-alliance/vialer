import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_brand.dart';
import '../../user/get_build_info.dart';
import '../../user/get_logged_in_user.dart';
import 'register_to_middleware.dart';
import 'voip.dart';
import 'voip_not_allowed.dart';

class StartVoipUseCase extends UseCase with Loggable {
  final _voipRepository = dependencyLocator<VoipRepository>();

  final _getUser = GetLoggedInUserUseCase();
  final _registerToMiddleware = RegisterToMiddlewareUseCase();
  final _getBrand = GetBrand();
  final _getBuildInfo = GetBuildInfoUseCase();

  Future<void> call() async {
    final user = _getUser();

    if (!user.isAllowedVoipCalling) {
      logger.warning(
        'Attempting to start a voip call while the user does is '
        'not allowed. This likely means they have no app account configured.',
      );
      throw VoipNotAllowedException();
    }

    await _voipRepository.initializeAndStart(
      user: user,
      clientConfig: user.client.voip,
      brand: _getBrand(),
      buildInfo: await _getBuildInfo(),
    );

    await _registerToMiddleware();
  }
}
