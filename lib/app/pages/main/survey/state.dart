import 'package:equatable/equatable.dart';

import '../../../../domain/feedback/survey/question.dart';
import '../../../../domain/feedback/survey/survey.dart';

abstract class SurveyState extends Equatable {
  const SurveyState(this.survey);
  final Survey? survey;

  @override
  List<Object?> get props => [survey];

  SurveyState copyWith({Survey survey});
}

class LoadingSurvey extends SurveyState {
  const LoadingSurvey([super.survey]);

  @override
  SurveyState copyWith({Survey? survey}) => LoadingSurvey(survey);
}

class ShowHelpUsPrompt extends SurveyState {
  const ShowHelpUsPrompt({
    required this.dontShowThisAgain,
    Survey? survey,
  }) : super(survey);
  final bool dontShowThisAgain;

  @override
  List<Object?> get props => [...super.props, dontShowThisAgain];

  @override
  ShowHelpUsPrompt copyWith({Survey? survey, bool? dontShowThisAgain}) {
    return ShowHelpUsPrompt(
      survey: survey ?? this.survey,
      dontShowThisAgain: dontShowThisAgain ?? this.dontShowThisAgain,
    );
  }
}

class ShowQuestion extends SurveyState {
  const ShowQuestion(
    this.question, {
    Survey? survey,
    this.answer,
    this.previous,
  }) : super(survey);
  final Question question;
  final int? answer;

  final ShowQuestion? previous;

  @override
  List<Object?> get props => [...super.props, question, answer, previous];

  @override
  ShowQuestion copyWith({
    Survey? survey,
    Question? question,
    int? answer,
    ShowQuestion? previous,
  }) {
    return ShowQuestion(
      question ?? this.question,
      survey: survey ?? this.survey,
      answer: answer ?? this.answer,
      previous: previous ?? this.previous,
    );
  }

  /// Returns a copy of this state with the [answer] cleared (`null`).
  ShowQuestion withoutAnswer() {
    return ShowQuestion(
      question,
      survey: survey,
      previous: previous,
    );
  }
}

class ShowThankYou extends SurveyState {
  const ShowThankYou(super.survey);

  @override
  ShowThankYou copyWith({Survey? survey}) {
    return ShowThankYou(survey ?? this.survey);
  }
}
