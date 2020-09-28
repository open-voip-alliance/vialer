import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'survey_location.dart';

import 'question.dart';

class Survey extends Equatable {
  final String id;

  /// Where the survey is shown in the app.
  final SurveyLocation location;

  /// The ISO 639-1 language code of the language the questions are in.
  final String language;

  final List<Question> questions;

  Survey({
    @required this.id,
    @required this.location,
    @required this.language,
    @required this.questions,
  })  : assert(id != null),
        assert(location != null),
        assert(language != null),
        assert(questions != null && questions.isNotEmpty);

  @override
  List<Object> get props => [id, location, language, questions];
}
