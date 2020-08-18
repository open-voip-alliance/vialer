import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/usecases/send_feedback.dart';

class FeedbackPresenter extends Presenter {
  Function feedbackSendOnComplete;

  final _sendFeedback = SendFeedbackUseCase();

  void sendFeedback({@required String title, @required String text}) {
    _sendFeedback(
      title: title,
      text: text,
    ).then((_) => feedbackSendOnComplete());
  }

  @override
  void dispose() {}
}
