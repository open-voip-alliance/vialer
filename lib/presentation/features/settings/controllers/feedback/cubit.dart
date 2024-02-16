import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/models/user/settings/app_setting.dart';
import '../../../../../../domain/usecases/feedback/send_feedback.dart';
import '../../../../../../domain/usecases/feedback/send_saved_logs_to_remote.dart';
import '../../../../../../domain/usecases/user/settings/change_setting.dart';
import 'state.dart';

export 'state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit() : super(FeedbackNotSent());
  final _sendFeedback = SendFeedbackUseCase();
  final _sendSavedLogsToRemote = SendSavedLogsToRemoteUseCase();
  final _changeSetting = ChangeSettingUseCase();

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
      unawaited(_sendSavedLogsToRemote());
    }
  }
}
