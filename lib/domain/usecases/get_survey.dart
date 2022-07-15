import 'dart:async';

import '../entities/survey/survey.dart';
import '../entities/survey/survey_trigger.dart';
import '../use_case.dart';
import 'get_app_rating_survey.dart';

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
