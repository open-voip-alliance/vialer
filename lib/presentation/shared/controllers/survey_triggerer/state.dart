import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../data/models/feedback/survey/survey.dart';
import '../../../../../data/models/feedback/survey/survey_trigger.dart';

part 'state.freezed.dart';

@freezed
sealed class SurveyTriggererState with _$SurveyTriggererState {
  const factory SurveyTriggererState.surveyNotTriggered() = SurveyNotTriggered;
  const factory SurveyTriggererState.surveyTriggered(
    SurveyId id,
    SurveyTrigger trigger,
  ) = SurveyTriggered;
}
