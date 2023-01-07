import 'package:freezed_annotation/freezed_annotation.dart';

import 'question.dart';
import 'survey_trigger.dart';

part 'survey.freezed.dart';

@freezed
class Survey with _$Survey {
  const factory Survey({
    required SurveyId id,

    /// Where and when the survey is shown in the app.
    required SurveyTrigger trigger,

    /// The ISO 639-1 language code of the language the questions are in.
    required String language,
    required List<Question> questions,

    /// Whether to skip the intro asking if people want
    /// to participate in the survey, useful for single question surveys.
    required bool skipIntro,
  }) = _Survey;
}

enum SurveyId {
  appRating,
}
