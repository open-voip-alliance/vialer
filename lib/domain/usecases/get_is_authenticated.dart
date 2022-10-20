import '../use_case.dart';
import 'get_stored_user.dart';

class GetIsAuthenticatedUseCase extends UseCase {
  final _getUser = GetStoredUserUseCase();

  bool call() => _getUser()?.token != null;
}
