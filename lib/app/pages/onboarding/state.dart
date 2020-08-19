import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/onboarding/step.dart';

class OnboardingState extends Equatable {
  /// All steps to go through in the onboarding process. Steps may be
  /// added later on during the onboarding process.
  ///
  /// For example, when the user is required to change their password,
  /// the `Step.password` will be added.
  final Iterable<OnboardingStep> allSteps;
  final OnboardingStep currentStep;

  final bool completed;

  OnboardingState({
    @required this.allSteps,
    @required this.currentStep,
    this.completed = false,
  });

  @override
  List<Object> get props => [allSteps, currentStep, completed];

  OnboardingState copyWith({
    Iterable<OnboardingStep> allSteps,
    OnboardingStep currentStep,
    bool completed,
  }) {
    return OnboardingState(
      allSteps: allSteps ?? this.allSteps,
      currentStep: currentStep ?? this.currentStep,
      completed: completed ?? this.completed,
    );
  }
}
