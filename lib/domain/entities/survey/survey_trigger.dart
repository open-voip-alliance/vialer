import 'package:dartx/dartx.dart';

/// When and where the survey is displayed.
class SurveyTrigger {
  static const afterThreeCallThroughCalls = AfterThreeCallThroughCallsTrigger();

  const SurveyTrigger();

  /// Converts for example `SurveyTrigger.afterThreeCallThroughCalls` to
  /// `'after-three-call-through-calls'`.
  String toJson() {
    final camelCaseSplit =
        toString().split('.')[1].split(RegExp(r'(?<=[a-z])(?=[A-Z])'));

    return camelCaseSplit
        .mapIndexed(
          (index, word) => index + 1 != camelCaseSplit.length ? '$word-' : word,
        )
        .join()
        .toLowerCase();
  }
}

class AfterThreeCallThroughCallsTrigger extends SurveyTrigger {
  static const callCount = 3;

  const AfterThreeCallThroughCallsTrigger();
}
