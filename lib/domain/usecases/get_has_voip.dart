import '../../dependency_locator.dart';

import '../repositories/auth.dart';
import '../use_case.dart';

class GetHasVoipUseCase extends UseCase<bool> {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  bool call() => _authRepository.currentUser?.appAccountId != null;
}
