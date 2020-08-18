import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/usecases/get_is_authenticated.dart';

class SplashPresenter extends Presenter {
  Function getIsAuthenticatedOnNext;

  final _getIsAuthenticated = GetIsAuthenticatedUseCase();

  void getAuthStatus() => _getIsAuthenticated().then(
        getIsAuthenticatedOnNext,
        onError: (_) => getIsAuthenticatedOnNext(false),
      );

  @override
  void dispose() {}
}
