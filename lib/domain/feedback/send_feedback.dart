import 'dart:async';

import '../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import 'feedback.dart';

class SendFeedbackUseCase extends UseCase {
  final _feedbackRepository = dependencyLocator<FeedbackRepository>();

  final _getUser = GetLoggedInUserUseCase();

  Future<void> call({
    required String title,
    required String text,
  }) async {
    await _feedbackRepository.send(
      title: title,
      text: text,
      user: _getUser(),
    );
  }
}
