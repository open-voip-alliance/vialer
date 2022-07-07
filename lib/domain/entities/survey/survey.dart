import 'package:equatable/equatable.dart';

import 'question.dart';
import 'survey_trigger.dart';

class Survey extends Equatable {
  final SurveyId id;

  /// Where and when the survey is shown in the app.
  final SurveyTrigger trigger;

  /// The ISO 639-1 language code of the language the questions are in.
  final String language;

  final List<Question> questions;

  /// Whether to skip the intro asking if people want
  /// to participate in the survey, useful for single question surveys.
  final bool skipIntro;

  Survey({
    required this.id,
    required this.trigger,
    required this.language,
    this.skipIntro = false,
    required this.questions,
  }) : assert(questions.isNotEmpty);

  @override
  List<Object?> get props => [id, trigger, language, skipIntro, questions];
}

enum SurveyId {
  callThrough1,
  appRating,
}