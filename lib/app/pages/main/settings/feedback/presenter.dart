import 'dart:io';

import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/feedback.dart';
import '../../../../../domain/repositories/auth.dart';

import '../../../../../domain/usecases/send_feedback.dart';

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
      _SendFeedbackUseCaseObserver(this),
      SendFeedbackUseCaseParams(
        title: title,
        text: text,
        platform: Platform.operatingSystem,
      ),
    );
  }

  @override
  void dispose() {
    _sendFeedbackUseCase.dispose();
  }
}

class _SendFeedbackUseCaseObserver extends Observer<void> {
  final FeedbackPresenter presenter;

  _SendFeedbackUseCaseObserver(this.presenter);

  @override
  void onComplete() => presenter.feedbackSendOnComplete();

  @override
  void onError(dynamic e) {}

  @override
  void onNext(_) {}
}
