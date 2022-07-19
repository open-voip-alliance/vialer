import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/setting.dart';
import '../../../../domain/entities/survey/survey.dart';
import '../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../domain/usecases/change_setting.dart';
import '../../../../domain/usecases/get_settings.dart';
import '../../../../domain/usecases/get_survey.dart';
import '../../../../domain/usecases/send_survey_results.dart';
import '../../../util/loggable.dart';
import 'state.dart';

export 'state.dart';

class SurveyCubit extends Cubit<SurveyState> with Loggable {
  final _getSurvey = GetSurveyUseCase();
  final _sendSurveyResults = SendSurveyResultsUseCase();

  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();

  SurveyCubit({
    required String language,
    required SurveyId id,
    required SurveyTrigger trigger,
  }) : super(const LoadingSurvey()) {
    _getSurvey(id, language: language, trigger: trigger).then((survey) {
      _getSettings().then((settings) {
        // Necessary for auto cast.
        final state = this.state;

        if (state is LoadingSurvey) {
          if (survey.skipIntro) {
            emit(
              ShowQuestion(
                survey.questions.first,
                survey: survey,
              ),
            );
          } else {
            emit(
              ShowHelpUsPrompt(
                survey: survey,
                dontShowThisAgain: !settings.get<ShowSurveysSetting>().value,
              ),
            );
          }
        }
      });
    });
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDontShowThisAgain(bool value) async {
    // Necessary for auto cast
    final state = this.state;

    if (state is ShowHelpUsPrompt) {
      emit(state.copyWith(dontShowThisAgain: value));
    }

    await _changeSetting(setting: ShowSurveysSetting(!value));
  }

  void previous() {
    if (state is ShowQuestion) {
      _progressToPreviousQuestion();
    }
  }

  void next() {
    if (state is ShowHelpUsPrompt) {
      emit(ShowQuestion(state.survey!.questions.first, survey: state.survey));
    } else if (state is ShowQuestion) {
      _progressToNextQuestion();
    }
  }

  void answerQuestion(int answer) {
    // Necessary for auto-cast
    final state = this.state as ShowQuestion;

    emit(
      answer == state.answer
          ? state.withoutAnswer()
          : state.copyWith(answer: answer),
    );
  }

  void _progressToNextQuestion() {
    final state = this.state as ShowQuestion;
    final survey = state.survey!;

    final indexOfCurrent = survey.questions.indexOf(state.question);

    if (indexOfCurrent == survey.questions.length - 1) {
      emit(ShowThankYou(state.survey));

      _sendSurveyResults(
        survey.id,
        data: _prepareSurveyResults(state),
      );

      return;
    }

    emit(
      ShowQuestion(
        survey.questions[indexOfCurrent + 1],
        survey: survey,
        previous: state,
      ),
    );
  }

  /// Prepares the results for surveys, customizing them based on the type of
  /// survey if necessary.
  Map<String, dynamic> _prepareSurveyResults(ShowQuestion state) {
    final survey = state.survey!;

    if (survey.id == SurveyId.appRating) {
      // Required for type promotion.
      final answer = state.answer;

      return {
        'rating': answer != null ? answer + 1 : null,
      };
    }

    return {
      'language': survey.language,
      'trigger': survey.trigger.toJson(),
      'questions': [
        for (ShowQuestion? s = state; s != null; s = s.previous)
          {
            'id': s.question.id,
            'phrase': s.question.phrase,
            'answer': {
              'id': s.answer,
              'phrase': s.question.answers[s.answer!],
            }
          },
      ].reversed.toList(),
    };
  }

  void _progressToPreviousQuestion() {
    final state = this.state as ShowQuestion;

    if (state.previous != null) {
      emit(state.previous!);
    }
  }
}
