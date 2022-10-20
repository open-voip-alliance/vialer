import 'dart:async';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/login_credentials.dart';
import '../entities/permission.dart';
import '../repositories/legacy_storage_repository.dart';
import '../repositories/metrics.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'onboarding/login.dart';
import 'onboarding/request_permission.dart';

/// Imports the credentials from the legacy app and uses this to log the user
/// in. This can be removed when all users have been migrated over.
class AutomaticallyLoginLegacyUser extends UseCase with Loggable {
  final _login = LoginUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final storageRepository = dependencyLocator<StorageRepository>();
  final legacyStorageRepository = dependencyLocator<LegacyStorageRepository>();

  Future<bool> call() async {
    /// If the user is already logged in, we don't need to do anything.
    if (storageRepository.user != null) return false;

    final token = legacyStorageRepository.token;
    final email = legacyStorageRepository.emailAddress;

    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return false;
    }

    logger.info(
      'Found legacy login credentials, attempting to automatically login.',
    );

    await _requestPermissions();

    final success = await _attemptLogin(token, email);

    if (!success) {
      logger.severe('Unable to login user with legacy credentials');
      _track(successful: false);
      return false;
    }

    logger.info('Automatic login was successful! Removing legacy credentials,');
    _track(successful: true);

    legacyStorageRepository.clear();

    return true;
  }

  void _track({required bool successful}) => _metricsRepository.track(
        'automatic-login-from-legacy-app',
        {
          'success': successful,
        },
      );

  Future<bool> _attemptLogin(String token, String email) async => await _login(
        credentials: ImportedLegacyAppCredentials(
          token,
          email,
        ),
      );

  /// These permissions should already be accepted, this is just to "refresh"
  /// the plugin so it knows that we have them.
  Future<void> _requestPermissions() async {
    for (var permission in [
      Permission.microphone,
      Permission.contacts,
      Permission.phone,
    ]) {
      await _requestPermission(permission: permission);
    }
  }
}
