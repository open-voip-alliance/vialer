import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class GetOutgoingCliUseCase extends UseCase<String> {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  String call() => _authRepository.currentUser?.outgoingCli;
}
