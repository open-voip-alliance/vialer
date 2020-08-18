import 'dart:async';

import '../repositories/auth.dart';
import '../use_case.dart';

class GetIsAuthenticatedUseCase extends FutureUseCase<bool> {
  final AuthRepository _authRepository;

  GetIsAuthenticatedUseCase(this._authRepository);

  @override
  Future<bool> call() => _authRepository.isAuthenticated();
}
