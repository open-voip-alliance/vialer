import 'dart:async';

import 'package:meta/meta.dart';

import '../repositories/feedback.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class SendFeedbackUseCase extends FutureUseCase<void> {
  final FeedbackRepository _feedbackRepository;
  final AuthRepository _authRepository;

  SendFeedbackUseCase(this._feedbackRepository, this._authRepository);

  @override
  Future<void> call({
    @required String title,
    @required String text,
    String brand = 'Vialer',
  }) async {
    final user = _authRepository.currentUser;

    await _feedbackRepository.send(
      title: title,
      text: text,
      user: user,
      brand: brand,
    );
  }
}
