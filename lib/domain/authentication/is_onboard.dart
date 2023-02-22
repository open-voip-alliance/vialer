import '../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';
import 'is_authenticated.dart';

/// Whether the user has completed onboarding. This also implies that the user
/// is logged in.
class IsOnboarded extends UseCase {
  final _isAuthenticated = IsAuthenticated();
  final _storage = dependencyLocator<StorageRepository>();

  bool call() => _isAuthenticated() && _storage.hasCompletedOnboarding;
}
