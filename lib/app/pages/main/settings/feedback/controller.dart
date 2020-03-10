import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/feedback.dart';
import '../../../../../domain/repositories/auth.dart';

import 'presenter.dart';

class DialerController extends Controller {
  final FeedbackPresenter _presenter;

  final titleController = TextEditingController();
  final textController = TextEditingController();

  DialerController(
    FeedbackRepository feedbackRepository,
    AuthRepository authRepository,
  ) : _presenter = FeedbackPresenter(feedbackRepository, authRepository);

  void sendFeedback() => _presenter.sendFeedback(
        title: titleController.text,
        text: textController.text,
      );

  void _onFeedbackSendComplete() => Navigator.pop(getContext(), true);

  @override
  void initListeners() {
    _presenter.feedbackSendOnComplete = _onFeedbackSendComplete;
  }
}
