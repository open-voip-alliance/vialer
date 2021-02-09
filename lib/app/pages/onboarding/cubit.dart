import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/onboarding/step.dart';
import '../../../domain/usecases/onboarding/get_steps.dart';
import '../../util/loggable.dart';
import '../main/widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class OnboardingCubit extends Cubit<OnboardingState> with Loggable {
  final _getSteps = GetOnboardingStepsUseCase();

  final CallerCubit _caller;

  OnboardingCubit(this._caller)
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
    final allSteps = List<OnboardingStep>.from(state.allSteps);

    final indexOfCurrent = allSteps.indexOf(state.currentStep);

    allSteps.insert(indexOfCurrent + 1, step);

    emit(
      state.copyWith(
        allSteps: allSteps,
      ),
    );
  }

  /// If [password] is set, it will be saved in the [OnboardingState], to
  /// be used by following steps.
  void forward({String password}) {
    final allSteps = state.allSteps.toList();

    final indexOfCurrent = allSteps.indexOf(state.currentStep);

    if (indexOfCurrent + 1 >= allSteps.length) {
      logger.info('Onboarding complete');

      _caller.initialize();
      emit(state.copyWith(completed: true));
    } else {
      _goTo(allSteps[indexOfCurrent + 1], password: password);
    }
  }

  void backward() {
    final allSteps = state.allSteps.toList();

    final indexOfCurrent = allSteps.indexOf(state.currentStep);

    if (indexOfCurrent - 1 >= 0) {
      _goTo(allSteps[indexOfCurrent - 1]);
    }
  }

  void _goTo(OnboardingStep step, {String password}) {
    logger.info('Progress step: ${state.currentStep} -> $step');

    emit(state.copyWith(currentStep: step, password: password));
  }
}
