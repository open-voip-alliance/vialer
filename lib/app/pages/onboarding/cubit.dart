import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/loggable.dart';

import '../../../domain/usecases/onboarding/get_steps.dart';
import '../../../domain/entities/onboarding/step.dart';

import 'state.dart';
export 'state.dart';

class OnboardingCubit extends Cubit<OnboardingState> with Loggable {
  final _getSteps = GetOnboardingStepsUseCase();

  OnboardingCubit()
      : super(
          OnboardingState(
            currentStep: OnboardingStep.login,
            allSteps: [OnboardingStep.login],
          ),
        ) {
    _getSteps().then((steps) {
      emit(
        state.copyWith(allSteps: steps),
      );
    });
  }

  /// Add a new next step.
  void addStep(OnboardingStep step) {
    final currentSteps = List<OnboardingStep>.from(state.allSteps);

    final indexOfCurrent = currentSteps.indexOf(state.currentStep);

    currentSteps.insert(indexOfCurrent + 1, step);

    emit(
      state.copyWith(
        allSteps: currentSteps,
      ),
    );
  }

  /// If [password] is set, it will be saved in the [OnboardingState], to
  /// be used by following steps.
  void forward({String password}) {
    final currentSteps = state.allSteps.toList();

    final indexOfCurrent = currentSteps.indexOf(state.currentStep);

    if (indexOfCurrent + 1 >= currentSteps.length) {
      logger.info('Onboarding complete');

      emit(state.copyWith(completed: true));
    } else {
      _goTo(currentSteps[indexOfCurrent + 1], password: password);
    }
  }

  void backward() {
    final currentSteps = state.allSteps.toList();

    final indexOfCurrent = currentSteps.indexOf(state.currentStep);

    if (indexOfCurrent - 1 >= 0) {
      _goTo(currentSteps[indexOfCurrent - 1]);
    }
  }

  void _goTo(OnboardingStep step, {String password}) {
    logger.info('Progress step: ${state.currentStep} -> $step');

    emit(state.copyWith(currentStep: step, password: password));
  }
}
