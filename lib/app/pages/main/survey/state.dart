import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/feedback/survey/question.dart';
import '../../../../domain/feedback/survey/survey.dart';

part 'state.freezed.dart';

@freezed
sealed class SurveyState with _$SurveyState {
  const factory SurveyState.loadingSurvey([Survey? survey]) = LoadingSurvey;
  const factory SurveyState.showHelpUsPrompt({
    required bool dontShowThisAgain,
    Survey? survey,
  }) = ShowHelpUsPrompt;
  const factory SurveyState.showQuestion(
    Question question, {
    Survey? survey,
    int? answer,
    ShowQuestion? previous,
  }) = ShowQuestion;
  const factory SurveyState.showThankYou(Survey? survey) = ShowThankYou;
}

extension WithoutAnswer on ShowQuestion {
  /// Returns a copy of this state with the [answer] cleared (`null`).
  ShowQuestion withoutAnswer() {
    return ShowQuestion(
      question,
      survey: survey,
      previous: previous,
    );
  }
}
