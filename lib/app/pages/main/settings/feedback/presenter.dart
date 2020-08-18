import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/feedback.dart';
import '../../../../../domain/repositories/auth.dart';

import '../../../../../domain/usecases/send_feedback.dart';

class FeedbackPresenter extends Presenter {
  Function feedbackSendOnComplete;

  final SendFeedbackUseCase _sendFeedback;

  FeedbackPresenter(
    FeedbackRepository feedbackRepository,
    AuthRepository authRepository,
  ) : _sendFeedback = SendFeedbackUseCase(
          feedbackRepository,
          authRepository,
        );

  void sendFeedback({@required String title, @required String text}) {
    _sendFeedback(
      title: title,
      text: text,
    ).then((_) => feedbackSendOnComplete());
  }

  @override
  void dispose() {}
}
