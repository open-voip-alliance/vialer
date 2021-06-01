import 'dart:async';

import '../../../dependency_locator.dart';
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
    required String email,
    required String password,
    String? twoFactorCode,
  }) async {
    final user = await _authRepository.authenticate(
      email,
      password,
      twoFactorCode: twoFactorCode,
    );

    if (user == null) {
      return false;
    }

    _storageRepository.systemUser = user;

    await _getLatestAvailability();
    await _identifyForTracking();
    await _trackLogin(usedTwoFactor: twoFactorCode != null);

    return true;
  }
}
