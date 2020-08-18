import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/repositories/permission.dart';
import '../../../domain/usecases/onboarding/get_steps.dart';

class OnboardingPresenter extends Presenter {
  Function getStepsOnNext;

  final GetStepsUseCase _getSteps;

  OnboardingPresenter(PermissionRepository callPermissionRepository)
      : _getSteps = GetStepsUseCase(callPermissionRepository);

  void getSteps() {
    _getSteps().then(getStepsOnNext);
  }

  @override
  void dispose() {}
}
