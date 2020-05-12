import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/repositories/permission.dart';
import '../../../domain/usecases/onboarding/get_steps.dart';

import '../main/util/observer.dart';

class OnboardingPresenter extends Presenter {
  Function getStepsOnNext;

  final GetStepsUseCase _getStepsUseCase;

  OnboardingPresenter(PermissionRepository callPermissionRepository)
      : _getStepsUseCase = GetStepsUseCase(callPermissionRepository);

  void getSteps() {
    _getStepsUseCase.execute(
      Watcher(
        onNext: getStepsOnNext,
      ),
    );
  }

  @override
  void dispose() {
    _getStepsUseCase.dispose();
  }
}
