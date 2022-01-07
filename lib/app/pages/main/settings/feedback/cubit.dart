import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/usecases/change_setting.dart';

import '../../../../../domain/usecases/send_feedback.dart';
import '../../../../../domain/usecases/send_saved_logs_to_remote.dart';
import 'state.dart';

export 'state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final _sendFeedback = SendFeedbackUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _changeSetting = ChangeSettingUseCase();

  FeedbackCubit() : super(FeedbackNotSent());

  Future<void> sendFeedback({
    required String title,
    required String text,
  }) async {
    emit(FeedbackSending());
    await _sendFeedback(title: title, text: text);
    emit(FeedbackSent());
  }

  Future<void> enableThenSendLogsToRemote() => _changeSetting(
        setting: const RemoteLoggingSetting(true),
      ).then((_) => _sendSavedLogsToRemote());
}
