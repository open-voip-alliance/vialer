import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/settings/app_setting.dart';
import '../../../../../domain/usecases/send_feedback.dart';
import '../../../../../domain/usecases/send_saved_logs_to_remote.dart';
import '../../../../../domain/usecases/settings/change_setting.dart';
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

  Future<void> enableThenSendLogsToRemote() async {
    final result = await _changeSetting(AppSetting.remoteLogging, true);

    if (result != SettingChangeResult.failed) {
      _sendSavedLogsToRemote();
    }
  }
}
