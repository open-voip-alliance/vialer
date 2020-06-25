import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../repositories/feedback.dart';
import '../repositories/auth.dart';

class SendFeedbackUseCase extends UseCase<void, SendFeedbackUseCaseParams> {
  final FeedbackRepository _feedbackRepository;
  final AuthRepository _authRepository;

  SendFeedbackUseCase(this._feedbackRepository, this._authRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(
    SendFeedbackUseCaseParams params,
  ) async {
    final controller = StreamController<void>();

    final user = _authRepository.currentUser;

    await _feedbackRepository.send(
      title: params.title,
      text: params.text,
      user: user,
      brand: params.brand,
    );
    unawaited(controller.close());

    return controller.stream;
  }
}

class SendFeedbackUseCaseParams {
  final String title;
  final String text;

  final String brand;

  SendFeedbackUseCaseParams({
    @required this.title,
    @required this.text,
    this.brand = 'Vialer',
  });
}
