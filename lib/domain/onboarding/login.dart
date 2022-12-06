import 'dart:async';

import '../metrics/identify_for_tracking.dart';
import '../metrics/track_login.dart';
import '../use_case.dart';
import '../user/refresh_user.dart';
import 'login_credentials.dart';
import 'mark_now_as_login_time.dart';

class LoginUseCase extends UseCase {
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _trackLogin = TrackLoginUseCase();
  final _markNowAsLoginTime = MarkNowAsLoginTimeUseCase();
  final _refreshUser = RefreshUser();

  Future<bool> call({
    required LoginCredentials credentials,
  }) async {
    final user = await _refreshUser(credentials: credentials);

    if (user == null) {
      return false;
    }

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
