export 'event.dart';
export 'state.dart';

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'event.dart';
import 'permission/call/bloc.dart';
import 'state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  @override
  OnboardingState get initialState => InitialStep();

  var _steps = List<Type>();
  var _current = 0;

  @override
  Stream<OnboardingState> mapEventToState(OnboardingEvent event) async* {
    if (event is CheckWhichStepsAreNeeded) {
      final steps = [InitialStep, LoginStep];

      if (await CallPermissionBloc.shouldAddStep()) {
        steps.add(CallPermissionStep);
      }

      _steps = steps;

      yield InitialStep(steps: steps);
    }

    if (event is Forward) {
      _current++;

      if (_current >= _steps.length) {
        yield OnboardingState.fromType(
          state.runtimeType,
          end: Direction.forward,
        );
        return;
      }

      yield OnboardingState.fromType(_steps[_current]);
    }

    if (event is Backward) {
      _current--;

      if (_current < 0) {
        yield OnboardingState.fromType(
          state.runtimeType,
          end: Direction.backward,
        );
        return;
      }

      yield OnboardingState.fromType(_steps[_current]);
    }
  }
}
