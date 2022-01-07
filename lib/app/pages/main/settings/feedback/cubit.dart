import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/usecases/enable_remote_logging.dart';
import '../../../../../domain/usecases/send_feedback.dart';
import '../../../../../domain/usecases/send_saved_logs_to_remote.dart';
import 'state.dart';

export 'state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final _sendFeedback = SendFeedbackUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();

  FeedbackCubit() : super(FeedbackNotSent());

  Future<void> sendFeedback({
    required String title,
    required String text,
  }) async {
    emit(FeedbackSending());
    await _sendFeedback(title: title, text: text);
    emit(FeedbackSent());
  }

  Future<void> enableThenSendLogsToRemote() =>
      _enableRemoteLogging().then((_) => _sendSavedLogsToRemote);
}
