import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:vialer/data/repositories/user/settings/settings_repository.dart';

import '../../user/settings/app_setting.dart';

/// When and where the survey is displayed.
class SurveyTrigger {
  const SurveyTrigger();

  /// Converts for example `AfterAnAmountOfActionsOnAppLaunchTrigger` to
  /// `'after-an-amount-of-actions-on-app-launch'`.
  String toJson() {
    final camelCaseSplit = runtimeType
        // ignore: no_runtimetype_tostring
        .toString()
        .replaceAll('Trigger', '')
        .split(RegExp('(?<=[a-z])(?=[A-Z])'));

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
class AfterAnAmountOfActionsOnAppLaunchTrigger extends SurveyTrigger {
  const AfterAnAmountOfActionsOnAppLaunchTrigger();

  /// Actions are calls or setting changes.
  static const actionsCount = 20;

  /// This duration is reset only if the user actually saw the survey.
  static const timePassedSinceLastSurvey = Duration(days: 28);

  static const percentChanceIfConditionsMet = 50;

  static bool isTriggered({
    required SettingsRepository settings,
    required int actionsCount,
    required Duration? timeSinceLastSurvey,
  }) {
    if (!settings.get(AppSetting.showSurveys)) return false;

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
