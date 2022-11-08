import '../use_case.dart';
import '../user/get_stored_user.dart';

class IsAuthenticated extends UseCase {
  final _getUser = GetStoredUserUseCase();

  bool call() => _getUser()?.token != null;
}
