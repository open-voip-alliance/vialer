import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/repositories/auth.dart';
import '../../../domain/usecases/get_auth_status.dart';

import '../main/util/observer.dart';

class SplashPresenter extends Presenter {
  Function getAuthStatusOnNext;

  final GetAuthStatusUseCase _useCase;

  SplashPresenter(AuthRepository authRepository)
      : _useCase = GetAuthStatusUseCase(authRepository);

  void getAuthStatus() => _useCase.execute(
        Watcher(
          onNext: getAuthStatusOnNext,
          onError: (e) => getAuthStatusOnNext(false),
        ),
      );

  @override
  void dispose() => _useCase.dispose();
}
