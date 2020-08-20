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

  /// User entered password, saved for if they need to change their password.
  final String password;

  final bool completed;

  OnboardingState({
    @required this.allSteps,
    @required this.currentStep,
    this.password,
    this.completed = false,
  });

  @override
  List<Object> get props => [allSteps, currentStep, password, completed];

  OnboardingState copyWith({
    Iterable<OnboardingStep> allSteps,
    OnboardingStep currentStep,
    String password,
    bool completed,
  }) {
    return OnboardingState(
      allSteps: allSteps ?? this.allSteps,
      currentStep: currentStep ?? this.currentStep,
      password: password ?? this.password,
      completed: completed ?? this.completed,
    );
  }
}
