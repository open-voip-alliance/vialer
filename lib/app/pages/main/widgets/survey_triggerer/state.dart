import 'package:equatable/equatable.dart';

import '../../../../../domain/feedback/survey/survey.dart';
import '../../../../../domain/feedback/survey/survey_trigger.dart';

abstract class SurveyTriggererState extends Equatable {
  const SurveyTriggererState();

  @override
  List<Object?> get props => [];
}

class SurveyNotTriggered extends SurveyTriggererState {
  const SurveyNotTriggered();
}

class SurveyTriggered extends SurveyTriggererState {
  const SurveyTriggered(this.id, this.trigger);

  final SurveyId id;
  final SurveyTrigger trigger;

  @override
  List<Object?> get props => [id, trigger];
}
