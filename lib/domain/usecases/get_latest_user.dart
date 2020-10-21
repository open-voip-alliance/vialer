import '../../dependency_locator.dart';
import '../entities/system_user.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

/// Fetches the latest user data remotely. Updates the cache automatically
/// as a side effect, so after this call [GetStoredUserUseCase] returns
/// the latest user data we have at the moment of the call.
class GetLatestUserUseCase extends FutureUseCase<SystemUser> {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  Future<SystemUser> call() => _authRepository.fetchLatestUser();
}
