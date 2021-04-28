import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/setting.dart';
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
    required SurveyTrigger trigger,
  }) : super(ShowHelpUsPrompt.uninitialized(dontShowThisAgain: false)) {
    _getSurvey(language: language, trigger: trigger).then((survey) {
      emit(state.copyWith(survey: survey));

      _getSettings().then((settings) {
        // Necessary for auto cast.
        final state = this.state;

        if (state is ShowHelpUsPrompt) {
          emit(
            state.copyWith(
              dontShowThisAgain: !settings.get<ShowSurveyDialogSetting>().value,
            ),
          );
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

    await _changeSetting(setting: ShowSurveyDialogSetting(!value));
  }

  void previous() {
    if (state is ShowQuestion) {
      _progressToPreviousQuestion();
    }
  }

  void next() {
    if (state is ShowHelpUsPrompt) {
      emit(ShowQuestion(state.survey.questions.first, survey: state.survey));
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

    final indexOfCurrent = state.survey.questions.indexOf(state.question);

    if (indexOfCurrent == state.survey.questions.length - 1) {
      emit(ShowThankYou(state.survey));

      // The survey is finished, so don't show it again
      _changeSetting(setting: const ShowSurveyDialogSetting(false));

      final survey = state.survey;

      _sendSurveyResults(
        data: {
          'id': survey.id,
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
        },
      );

      return;
    }

    emit(
      ShowQuestion(
        state.survey.questions[indexOfCurrent + 1],
        survey: state.survey,
        previous: state,
      ),
    );
  }

  void _progressToPreviousQuestion() {
    final state = this.state as ShowQuestion;

    if (state.previous != null) {
      emit(state.previous!);
    }
  }
}
