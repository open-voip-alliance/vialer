import 'package:injectable/injectable.dart';
import 'package:vialer/data/repositories/legacy/storage.dart';
import 'package:vialer/domain/usecases/use_case.dart';

import '../../../global.dart';

@injectable
class SkipMessagingSurvey extends UseCase {
  SkipMessagingSurvey(this.storageRepository);

  final StorageRepository storageRepository;

  Future<void> call() async {
    storageRepository.hasSubmittedMessagingAppsSurvey = true;
    track('messaging-apps-survey-skipped');
  }
}
