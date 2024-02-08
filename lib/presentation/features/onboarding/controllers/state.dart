import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../data/models/onboarding/step.dart';

part 'state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    /// All steps to go through in the onboarding process. Steps may be
    /// added later on during the onboarding process.
    ///
    /// For example, when the user is required to change their password,
    /// the `OnboardingStep.password` will be added.
    required Iterable<OnboardingStep> allSteps,
    required OnboardingStep currentStep,

    /// User entered email, saved for if they need to change their password.
    String? email,

    /// User entered password, saved for if they need to change their password.
    String? password,
    @Default(false) bool completed,
  }) = _OnboardingState;
}
