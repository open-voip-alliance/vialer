import 'dart:math';

import 'package:dartx/dartx.dart';

import '../setting.dart';

/// When and where the survey is displayed.
class SurveyTrigger {
  static const afterThreeCallThroughCalls = AfterThreeCallThroughCallsTrigger();

  const SurveyTrigger();

  /// Converts for example `AfterThreeCallThroughCallsTrigger` to
  /// `'after-three-call-through-calls'`.
  String toJson() {
    final camelCaseSplit = runtimeType
        .toString()
        .replaceAll('Trigger', '')
        .split(RegExp(r'(?<=[a-z])(?=[A-Z])'));

    return camelCaseSplit
        .mapIndexed(
          (index, word) => index + 1 != camelCaseSplit.length ? '$word-' : word,
        )
        .join()
        .toLowerCase();
  }
}

// WARNING: Do not change the name of this or any other subclasses of
// SurveyTrigger, because the name of the class is used for JSON serialization.
class AfterThreeCallThroughCallsTrigger extends SurveyTrigger {
  static const callCount = 3;

  /// Amount of calls when the survey should not be shown anymore, at least
  /// by default.
  static const ignoreCallCount = callCount * 2;
  static const minimumCallDuration = Duration(seconds: 30);

  const AfterThreeCallThroughCallsTrigger();

  static bool isTriggered(
    ShowSurveysSetting setting, {
    required int callCount,
  }) {
    return setting.value == true &&
        callCount >= AfterThreeCallThroughCallsTrigger.callCount;
  }
}

class AfterAnAmountOfActionsOnAppLaunchTrigger extends SurveyTrigger {
  /// Actions are calls or setting changes.
  static const actionsCount = 20;

  /// This duration is reset only if the user actually saw the survey.
  static const timePassedSinceLastSurvey = Duration(days: 28);

  static const percentChanceIfConditionsMet = 50;

  const AfterAnAmountOfActionsOnAppLaunchTrigger();

  static bool isTriggered(
    ShowSurveysSetting setting, {
    required int actionsCount,
    required Duration? timeSinceLastSurvey,
  }) {
    if (setting.value != true) return false;

    const requiredActionsCount =
        AfterAnAmountOfActionsOnAppLaunchTrigger.actionsCount;
    const requiredTimePassedSinceLastSurvey =
        AfterAnAmountOfActionsOnAppLaunchTrigger.timePassedSinceLastSurvey;

    return actionsCount >= requiredActionsCount &&
        (timeSinceLastSurvey == null ||
            timeSinceLastSurvey >= requiredTimePassedSinceLastSurvey) &&
        (Random().nextInt(100) <= percentChanceIfConditionsMet);
  }
}
