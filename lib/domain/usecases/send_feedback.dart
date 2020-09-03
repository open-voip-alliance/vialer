import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/feedback.dart';
import '../use_case.dart';

class SendFeedbackUseCase extends FutureUseCase<void> {
  final _feedbackRepository = dependencyLocator<FeedbackRepository>();

  @override
  Future<void> call({
    @required String title,
    @required String text,
  }) async {
    await _feedbackRepository.send(
      title: title,
      text: text,
    );
  }
}
