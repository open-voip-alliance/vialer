import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/feedback.dart';
import '../use_case.dart';
import 'get_user.dart';

class SendFeedbackUseCase extends UseCase {
  final _feedbackRepository = dependencyLocator<FeedbackRepository>();

  final _getUser = GetUserUseCase();

  Future<void> call({
    required String title,
    required String text,
  }) async {
    await _feedbackRepository.send(
      title: title,
      text: text,
      user: await _getUser(latest: false).then((u) => u!),
    );
  }
}
