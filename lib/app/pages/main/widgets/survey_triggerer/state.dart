import 'package:equatable/equatable.dart';

import '../../../../../domain/entities/survey/survey.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';

abstract class SurveyTriggererState extends Equatable {
  const SurveyTriggererState();

  @override
  List<Object?> get props => [];
}

class SurveyNotTriggered extends SurveyTriggererState {
  const SurveyNotTriggered();
}

class SurveyTriggered extends SurveyTriggererState {
  final SurveyId id;
  final SurveyTrigger trigger;

  const SurveyTriggered(this.id, this.trigger);

  @override
  List<Object?> get props => [id, trigger];
}
