import '../repositories/auth.dart';
import '../use_case.dart';

class GetOutgoingCliUseCase extends UseCase<String> {
  final AuthRepository _authRepository;

  GetOutgoingCliUseCase(this._authRepository);

  @override
  String call() => _authRepository.currentUser?.outgoingCli;
}
