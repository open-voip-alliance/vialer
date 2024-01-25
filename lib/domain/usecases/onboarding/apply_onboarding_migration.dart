import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../authentication/is_authenticated.dart';
import '../use_case.dart';

/// This runs when the app starts. Will fix the fact that
/// `hasCompletedOnboarding` is not set for users upgrading from an older
/// version. We assume they are logged in, if they're authenticated.
///
/// If the user was upgrading from an older version, was logged in but
/// didn't complete onboarding, their app will be broken. But this is such
/// a small percentage of users (likely even 0%) that it won't be considered.
class ApplyOnboardingMigration extends UseCase {
  final _isAuthenticated = IsAuthenticated();
  final _storageRepository = dependencyLocator<StorageRepository>();

  void call() {
    if (_storageRepository.hasCompletedOnboardingOrNull != null) return;

    _storageRepository.hasCompletedOnboarding = _isAuthenticated();
  }
}
