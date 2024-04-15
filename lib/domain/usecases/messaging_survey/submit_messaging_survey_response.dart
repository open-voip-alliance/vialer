import 'package:injectable/injectable.dart';
import 'package:vialer/data/models/messaging_survey/messaging_survey_response.dart';
import 'package:vialer/data/repositories/legacy/storage.dart';
import 'package:vialer/domain/usecases/use_case.dart';

import '../../../global.dart';

@injectable
class SubmitMessagingSurveyResponse extends UseCase {
  SubmitMessagingSurveyResponse(this.storageRepository);

  final StorageRepository storageRepository;

  Future<void> call(MessagingSurveyResponse response) async {
    storageRepository.hasSubmittedMessagingAppsSurvey = true;

    track('messaging-apps-survey-submitted', {
      'installed-messaging-app': response.installedApps,
      'question-personal-whatsapp': response.questionPersonalWhatsapp,
      'question-business-whatsapp': response.questionBusinessWhatsapp,
      'join-voys-research-pool': response.joinResearchPool,
    });
  }
}
