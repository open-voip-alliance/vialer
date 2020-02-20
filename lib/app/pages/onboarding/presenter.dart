import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/entities/onboarding/step.dart';
import '../../../domain/repositories/call_permission.dart';
import '../../../domain/usecases/onboarding/get_steps.dart';

class OnboardingPresenter extends Presenter {
  Function getStepsOnNext;

  final GetStepsUseCase _getStepsUseCase;

  OnboardingPresenter(CallPermissionRepository callPermissionRepository)
      : _getStepsUseCase = GetStepsUseCase(callPermissionRepository);

  void getSteps() {
    _getStepsUseCase.execute(_GetStepsUseCaseObserver(this));
  }

  @override
  void dispose() {
    _getStepsUseCase.dispose();
  }
}

class _GetStepsUseCaseObserver extends Observer<List<Step>> {
  final OnboardingPresenter presenter;

  _GetStepsUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(List<Step> steps) => presenter.getStepsOnNext(steps);
}
