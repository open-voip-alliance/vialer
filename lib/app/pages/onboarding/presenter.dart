import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/usecases/onboarding/get_steps.dart';

class OnboardingPresenter extends Presenter {
  Function getStepsOnNext;

  final _getSteps = GetStepsUseCase();

  void getSteps() {
    _getSteps().then(getStepsOnNext);
  }

  @override
  void dispose() {}
}
