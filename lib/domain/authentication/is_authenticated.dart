import '../use_case.dart';
import '../user/get_stored_user.dart';

/// Whether the user is logged in. Most of the time you'll want to use
/// [IsOnboarded] instead.
class IsAuthenticated extends UseCase {
  final _getUser = GetStoredUserUseCase();

  bool call() => _getUser()?.token != null;
}
