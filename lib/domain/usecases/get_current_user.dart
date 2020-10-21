import '../../dependency_locator.dart';
import '../entities/system_user.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class GetStoredUserUseCase extends UseCase<SystemUser> {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  SystemUser call() => _authRepository.currentUser;
}
