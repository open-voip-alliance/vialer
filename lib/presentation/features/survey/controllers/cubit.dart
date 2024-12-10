import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:vialer/data/models/user/user.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../data/models/feedback/survey/survey.dart';
import '../../../../../data/models/feedback/survey/survey_trigger.dart';
import '../../../../../data/models/user/settings/app_setting.dart';
import '../../../../../domain/usecases/feedback/send_survey_results.dart';
import '../../../../../domain/usecases/feedback/survey/get_survey.dart';
import '../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../domain/usecases/user/settings/change_setting.dart';
import 'state.dart';

export 'state.dart';

class SurveyCubit extends Cubit<SurveyState> with Loggable {
  SurveyCubit({
    required String language,
    required SurveyId id,
    required SurveyTrigger trigger,
  }) : super(const LoadingSurvey()) {
    unawaited(
      _getSurvey(id, language: language, trigger: trigger).then((survey) {
        final user = _getUser();
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
                dontShowThisAgain: !user.settings.get(
                  AppSetting.showSurveys,
                ),
              ),
            );
          }
        }
      }),
    );
  }

  final _getSurvey = GetSurveyUseCase();
  final _sendSurveyResults = SendSurveyResultsUseCase();

  final _getUser = GetLoggedInUserUseCase();
  final _changeSetting = ChangeSettingUseCase();

// ignore: avoid_positional_boolean_parameters
  Future<void> setDontShowThisAgain(bool value) async {
    // Necessary for auto cast
    final state = this.state;

    if (state is ShowHelpUsPrompt) {
      emit(state.copyWith(dontShowThisAgain: value));
    }

    await _changeSetting(AppSetting.showSurveys, !value);
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
      unawaited(_appStoreRatingCheck());
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

  Future<void> _appStoreRatingCheck() async {
    final state = this.state as ShowQuestion;
    final survey = state.survey!;

    if (survey.id != SurveyId.appRating) return;

    final answer = state.answer;
    final rating = _getRatingFromAnswer(answer) ?? 0;
    final shouldRequestAppStoreRating = rating > 3;

    if (shouldRequestAppStoreRating) {
      final inAppReview = InAppReview.instance;

      if (await inAppReview.isAvailable()) {
        unawaited(inAppReview.requestReview());
      }
    }
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
        'rating': _getRatingFromAnswer(answer),
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
            },
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

  int? _getRatingFromAnswer(int? answer) => answer != null ? answer + 1 : null;
}
