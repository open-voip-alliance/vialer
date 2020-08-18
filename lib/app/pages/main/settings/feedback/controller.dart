import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import 'presenter.dart';

class DialerController extends Controller {
  final _presenter = FeedbackPresenter();

  final titleController = TextEditingController();
  final textController = TextEditingController();

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
