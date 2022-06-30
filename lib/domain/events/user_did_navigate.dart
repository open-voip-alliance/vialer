import '../entities/navigation_destination.dart';

/// Broadcasted when the user navigates to a different page within the app's
/// main navigation.
class UserDidNavigate {
  final NavigationDestination? from;
  final NavigationDestination to;

  const UserDidNavigate(this.from, this.to);
}
