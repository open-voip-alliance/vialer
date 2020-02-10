import 'package:equatable/equatable.dart';

enum Direction {
  backward,
  forward,
}

abstract class OnboardingState extends Equatable {
  /// Direction if requested to go forward or backward on a state that has
  /// no previous or next. Null otherwise.
  final Direction end;

  OnboardingState(this.end);

  factory OnboardingState.fromType(Type type, {Direction end}) {
    switch (type) {
      case InitialStep: return InitialStep(end: end);
      case LoginStep: return LoginStep(end: end);
      case CallPermissionStep: return CallPermissionStep(end: end);
      default: throw UnsupportedError('Type is not supported');
    }
  }

  @override
  List<Object> get props => [end];
}

class InitialStep extends OnboardingState {
  final List<Type> steps;

  InitialStep({this.steps, Direction end}) : super(end);

  @override
  List<Object> get props => super.props + [steps];
}

class LoginStep extends OnboardingState {
  LoginStep({Direction end}) : super(end);
}

class CallPermissionStep extends OnboardingState {
  CallPermissionStep({Direction end}) : super(end);
}
