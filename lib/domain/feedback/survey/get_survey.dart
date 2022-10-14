import 'dart:async';

import '../../use_case.dart';
import 'get_app_rating_survey.dart';
import 'survey.dart';
import 'survey_trigger.dart';

class GetSurveyUseCase extends UseCase {
  final _getAppRatingSurvey = GetAppRatingSurvey();

  Future<Survey> call(
    SurveyId id, {
    required String language,
    required SurveyTrigger trigger,
  }) {
    switch (id) {
      case SurveyId.appRating:
        return _getAppRatingSurvey(language: language, trigger: trigger);
    }
  }
}
