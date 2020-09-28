import 'package:dartx/dartx.dart';

/// Where the survey is displayed.
enum SurveyLocation {
  afterThreeCallThroughCalls,
}

extension SurveyLocationToJson on SurveyLocation {
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
