import 'dart:async';

import '../../../dependency_locator.dart';
import '../../entities/login_credentials.dart';
import '../../entities/system_user.dart';
import '../../repositories/auth.dart';
import '../../repositories/storage.dart';
import '../../use_case.dart';
import '../get_latest_availability.dart';
import '../metrics/identify_for_tracking.dart';
import '../metrics/track_login.dart';

class LoginUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _identifyForTracking = IdentifyForTrackingUseCase();
  final _trackLogin = TrackLoginUseCase();
  final _getLatestAvailability = GetLatestAvailabilityUseCase();

  Future<bool> call({
    required LoginCredentials credentials,
  }) async {
    final user = await _getUserFromCredentials(credentials);

    if (user == null) {
      return false;
    }

    _storageRepository.systemUser = user;

    await _getLatestAvailability();
    await _identifyForTracking();
    await _trackLogin(usedTwoFactor: _isUsingTwoFactor(credentials));

    return true;
  }

  Future<SystemUser?> _getUserFromCredentials(
    LoginCredentials credentials,
  ) async {
    if (credentials is UserProvidedCredentials) {
      return await _authRepository.authenticate(
        credentials.email,
        credentials.password,
        twoFactorCode: credentials.twoFactorCode,
      );
    }

    if (credentials is ImportedLegacyAppCredentials) {
      return await _authRepository
          .getUserUsingProvidedCredentials(
            email: credentials.email,
            token: credentials.token,
          )
          .then((user) => user.copyWith(token: credentials.token));
    }

    return null;
  }

  bool _isUsingTwoFactor(LoginCredentials credentials) {
    if (credentials is UserProvidedCredentials) {
      return credentials.twoFactorCode != null;
    }

    return false;
  }
}
