import 'dart:async';

import '../entities/survey/question.dart';
import '../entities/survey/survey.dart';
import '../entities/survey/survey_trigger.dart';
import '../use_case.dart';

class GetSurveyUseCase extends UseCase {
  Future<Survey> call({
    required String language,
    required SurveyTrigger trigger,
  }) async {
    // This use case acts like an API could in the future.

    const surveyId = 'call-through-1';

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
          questions: [
            Question(
              id: 0,
              phrase: 'Hoe makkelijk was het om een gesprek op te zetten?',
              answers: [
                'Heel moeilijk',
                'Moeilijk',
                'Neutraal',
                'Makkelijk',
                'Heel makkelijk',
              ],
            ),
            Question(
              id: 1,
              phrase: 'Hoe waarschijnlijk is het dat je deze app blijft'
                  ' gebruiken om te bellen?',
              answers: [
                'Heel onwaarschijnlijk',
                'Onwaarschijnlijk',
                'Neutraal',
                'Waarschijnlijk',
                'Heel waarschijnlijk',
              ],
            ),
            Question(
              id: 2,
              phrase: 'Hoe duidelijk is het dat deze app je zakelijke nummer'
                  ' gebruikt voor uitgaande gesprekken?',
              answers: [
                'Heel onduidelijk',
                'Onduidelijk',
                'Neutraal',
                'Duidelijk',
                'Heel duidelijk',
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
          questions: [
            Question(
              id: 0,
              phrase: 'How easy was it to set up your call?',
              answers: [
                'Very difficult',
                'Difficult',
                'Neutral',
                'Easy',
                'Very easy',
              ],
            ),
            Question(
              id: 1,
              phrase: 'How likely is it that you\'re going to'
                  ' continue calling with this app?',
              answers: [
                'Very unlikely',
                'Unlikely',
                'Neutral',
                'Likely',
                'Very likely',
              ],
            ),
            Question(
              id: 2,
              phrase: 'How clear is it that this app uses your'
                  ' business number for outgoing calls?',
              answers: [
                'Very unclear',
                'Unclear',
                'Neutral',
                'Clear',
                'Very clear',
              ],
            ),
          ],
        );
    }
  }
}
