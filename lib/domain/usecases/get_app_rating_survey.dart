import 'dart:async';

import '../entities/survey/question.dart';
import '../entities/survey/survey.dart';
import '../entities/survey/survey_trigger.dart';
import '../use_case.dart';

class GetAppRatingSurvey extends UseCase {
  Future<Survey> call({
    required String language,
    required SurveyTrigger trigger,
  }) async {
    const surveyId = SurveyId.appRating;

    // !! Warning !!
    // If anything is changed to the survey questions after roll out, the
    // surveys will not match old data. If the surveys need to be changed,
    // use a new surveyId, after consulting the team.
    switch (language) {
      case 'nl':
        return Survey(
          id: surveyId,
          trigger: trigger,
          language: language,
          skipIntro: true,
          questions: [
            Question(
              id: 0,
              phrase: 'Wat vind je van de app?',
              answers: [
                'Heel slecht',
                'Slecht',
                'Oké',
                'Goed',
                'Heel goed',
              ],
            ),
          ],
        );
      case 'en':
      default:
        return Survey(
          id: surveyId,
          trigger: trigger,
          language: language,
          skipIntro: true,
          questions: [
            Question(
              id: 0,
              phrase: 'What do you think of the app?',
              answers: [
                'Very bad',
                'Bad',
                'Okay',
                'Good',
                'Very good',
              ],
            ),
          ],
        );
    }
  }
}
