import 'package:dartx/dartx.dart';

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

  const AfterThreeCallThroughCallsTrigger();
}
