import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../authentication/is_authenticated.dart';
import '../use_case.dart';

/// Whether the user has completed onboarding. This also implies that the user
/// is logged in.
class IsOnboarded extends UseCase {
  final _isAuthenticated = IsAuthenticated();
  final _storage = dependencyLocator<StorageRepository>();

  bool call() => _isAuthenticated() && _storage.hasCompletedOnboarding;
}
