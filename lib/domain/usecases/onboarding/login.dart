import 'dart:async';

import '../../../dependency_locator.dart';
import '../../entities/login_credentials.dart';
import '../../repositories/storage.dart';
import '../../use_case.dart';
import '../get_latest_user.dart';
import '../mark_now_as_login_time.dart';
import '../metrics/identify_for_tracking.dart';
import '../metrics/track_login.dart';

class LoginUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _trackLogin = TrackLoginUseCase();
  final _markNowAsLoginTime = MarkNowAsLoginTimeUseCase();
  final _getLatestUser = GetLatestUserUseCase();

  Future<bool> call({
    required LoginCredentials credentials,
  }) async {
    final user = await _getLatestUser(credentials);

    if (user == null) {
      return false;
    }

    _storageRepository.user = user;

    _track(
      usedTwoFactor: _isUsingTwoFactor(credentials),
      isLoginFromLegacyApp: credentials is ImportedLegacyAppCredentials,
    );
    _markNowAsLoginTime();

    return true;
  }

  Future<void> _track({
    required bool usedTwoFactor,
    required bool isLoginFromLegacyApp,
  }) async {
    await _identifyForTracking();
    await _trackLogin(
      usedTwoFactor: usedTwoFactor,
      isLoginFromLegacyApp: isLoginFromLegacyApp,
    );
  }

  bool _isUsingTwoFactor(LoginCredentials credentials) {
    if (credentials is UserProvidedCredentials) {
      return credentials.twoFactorCode != null;
    }

    return false;
  }
}
