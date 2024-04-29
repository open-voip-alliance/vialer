import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/usecases/messaging_survey/skip_messaging_survey.dart';

import '../../../../data/models/messaging_survey/messaging_survey_response.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../domain/usecases/messaging_survey/submit_messaging_survey_response.dart';
part 'riverpod.g.dart';

part 'riverpod.freezed.dart';

@Riverpod()
class MessagingSurveyController extends _$MessagingSurveyController {
  late final _storageRepository = dependencyLocator<StorageRepository>();
  late final _submitSurvey = dependencyLocator<SubmitMessagingSurveyResponse>();
  late final _skipSurvey = dependencyLocator<SkipMessagingSurvey>();

  /// Holds the current survey progress.
  var response = MessagingSurveyResponse();

  MessagingSurveyState build() =>
      _storageRepository.hasSubmittedMessagingAppsSurvey
          ? MessagingSurveyState.completed()
          : MessagingSurveyState.ready();

  Future<void> submit() async {
    await _submitSurvey(response);
    state = build();
  }

  Future<void> skipSurvey() async {
    await _skipSurvey();
    state = build();
  }
}

@freezed
class MessagingSurveyState with _$MessagingSurveyState {
  const factory MessagingSurveyState.ready() = Ready;
  const factory MessagingSurveyState.completed() = Completed;
}
