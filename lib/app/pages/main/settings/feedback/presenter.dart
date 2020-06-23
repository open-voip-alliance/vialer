import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/feedback.dart';
import '../../../../../domain/repositories/auth.dart';

import '../../../../../domain/usecases/send_feedback.dart';

import '../../util/observer.dart';

class FeedbackPresenter extends Presenter {
  Function feedbackSendOnComplete;

  final SendFeedbackUseCase _sendFeedbackUseCase;

  FeedbackPresenter(
    FeedbackRepository feedbackRepository,
    AuthRepository authRepository,
  ) : _sendFeedbackUseCase = SendFeedbackUseCase(
          feedbackRepository,
          authRepository,
        );

  void sendFeedback({@required String title, @required String text}) {
    _sendFeedbackUseCase.execute(
      Watcher(
        onComplete: feedbackSendOnComplete,
      ),
      SendFeedbackUseCaseParams(
        title: title,
        text: text,
      ),
    );
  }

  @override
  void dispose() {
    _sendFeedbackUseCase.dispose();
  }
}
