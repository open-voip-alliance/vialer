import 'package:equatable/equatable.dart';

import '../../../../domain/entities/survey/question.dart';
import '../../../../domain/entities/survey/survey.dart';

abstract class SurveyState extends Equatable {
  final Survey? survey;

  const SurveyState(this.survey);

  @override
  List<Object?> get props => [survey];

  SurveyState copyWith({Survey survey});
}

class ShowHelpUsPrompt extends SurveyState {
  final bool dontShowThisAgain;

  const ShowHelpUsPrompt({
    Survey? survey,
    required this.dontShowThisAgain,
  }) : super(survey);

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
  final Question question;
  final int? answer;

  final ShowQuestion? previous;

  const ShowQuestion(
    this.question, {
    Survey? survey,
    this.answer,
    this.previous,
  }) : super(survey);

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
      answer: null,
      previous: previous,
    );
  }
}

class ShowThankYou extends SurveyState {
  const ShowThankYou(Survey? survey) : super(survey);

  @override
  ShowThankYou copyWith({Survey? survey}) {
    return ShowThankYou(survey ?? this.survey);
  }
}
