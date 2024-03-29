import 'dart:async';

import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../authentication/is_authenticated.dart';
import '../authentication/logout.dart';
import '../use_case.dart';

/// Returns `true` if we should start onboarding. Only for use when the app
/// starts.
///
/// If the user is logged in but didn't finish onboarding, this returns `true`
/// as well. In that case, the user is also logged out.
class ShouldOnboard extends UseCase {
  final _isAuthenticated = IsAuthenticated();
  final _logout = Logout();
  final _storageRepository = dependencyLocator<StorageRepository>();

  bool call() {
    if (!_isAuthenticated()) return true;

    if (!_storageRepository.hasCompletedOnboarding) {
      unawaited(_logout());
      return true;
    }

    return false;
  }
}
