import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dependency_locator.dart';
import '../../../domain/legacy/storage.dart';
import '../../../domain/onboarding/get_steps.dart';
import '../../../domain/onboarding/step.dart';
import '../../util/loggable.dart';
import '../main/widgets/caller.dart';
import 'state.dart';

export 'state.dart';

class OnboardingCubit extends Cubit<OnboardingState> with Loggable {
  final _storage = dependencyLocator<StorageRepository>();

  final _getSteps = GetOnboardingStepsUseCase();

  final CallerCubit _caller;

  OnboardingCubit(this._caller)
      : super(
          const OnboardingState(
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

    final indexOfCurrent = allSteps.lastIndexOf(state.currentStep);

    allSteps.insert(indexOfCurrent + 1, step);

    emit(
      state.copyWith(
        allSteps: allSteps,
      ),
    );
  }

  /// If [email] and/or [password] is set, it will be saved in
  /// the [OnboardingState], to be used by following steps.
  void forward({String? email, String? password}) {
    final allSteps = state.allSteps.toList();

    final indexOfCurrent = allSteps.lastIndexOf(state.currentStep);

    if (indexOfCurrent + 1 >= allSteps.length) {
      logger.info('Onboarding complete');

      _storage.hasCompletedOnboarding = true;

      _caller.initialize();
      emit(state.copyWith(completed: true));
    } else {
      _goTo(allSteps[indexOfCurrent + 1], email, password);
    }
  }

  void backward() {
    final allSteps = state.allSteps.toList();

    final indexOfCurrent = allSteps.lastIndexOf(state.currentStep);

    if (indexOfCurrent - 1 >= 0) {
      _goTo(allSteps[indexOfCurrent - 1]);
    }
  }

  void _goTo(OnboardingStep step, [String? email, String? password]) {
    logger.info('Progress step: ${state.currentStep} -> $step');

    emit(
      state.copyWith(
        currentStep: step,
        email: email,
        password: password,
      ),
    );
  }

  Future<void> addMobileNumberStep() async =>
      addStep(OnboardingStep.mobileNumber);
}
