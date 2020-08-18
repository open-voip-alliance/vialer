import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class GetIsAuthenticatedUseCase extends FutureUseCase<bool> {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  Future<bool> call() => _authRepository.isAuthenticated();
}
