import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckWhichStepsAreNeeded extends OnboardingEvent {}

class Forward extends OnboardingEvent {}

class Backward extends OnboardingEvent {}
