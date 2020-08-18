import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/repositories/auth.dart';
import '../../../domain/usecases/get_is_authenticated.dart';

class SplashPresenter extends Presenter {
  Function getIsAuthenticatedOnNext;

  final GetIsAuthenticatedUseCase _getIsAuthenticated;

  SplashPresenter(AuthRepository authRepository)
      : _getIsAuthenticated = GetIsAuthenticatedUseCase(authRepository);

  void getAuthStatus() => _getIsAuthenticated().then(
        getIsAuthenticatedOnNext,
        onError: (_) => getIsAuthenticatedOnNext(false),
      );

  @override
  void dispose() {}
}
