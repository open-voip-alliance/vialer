import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/usecases/send_feedback.dart';

import 'state.dart';
export 'state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final _sendFeedback = SendFeedbackUseCase();

  FeedbackCubit() : super(FeedbackNotSent());

  Future<void> sendFeedback({
    @required String title,
    @required String text,
  }) async {
    await _sendFeedback(title: title, text: text);
    emit(FeedbackSent());
  }
}
