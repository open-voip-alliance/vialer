import '../entities/system_user.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class GetCurrentUserUseCase extends UseCase<SystemUser> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  SystemUser call() => _authRepository.currentUser;
}
