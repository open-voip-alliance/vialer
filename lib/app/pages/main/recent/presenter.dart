import 'package:meta/meta.dart';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/usecases/call.dart';

import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/usecases/get_recent_calls.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/usecases/get_settings.dart';

class RecentPresenter extends Presenter {
  Function recentCallsOnNext;
  Function recentCallsOnError;

  Function callOnError;

  Function settingsOnNext;

  final GetRecentCallsUseCase _getRecentCalls;
  final CallUseCase _call;
  final GetSettingsUseCase _getSettings;

  RecentPresenter(
    RecentCallRepository recentCallRepository,
    CallRepository callRepository,
    SettingRepository settingRepository,
  )   : _getRecentCalls = GetRecentCallsUseCase(recentCallRepository),
        _getSettings = GetSettingsUseCase(settingRepository),
        _call = CallUseCase(callRepository);

  void getRecentCalls({@required int page}) {
    _getRecentCalls(page: page).then(
      recentCallsOnNext,
      onError: recentCallsOnError,
    );
  }

  void call(String destination) =>
      _call(destination: destination).catchError(callOnError);

  void getSettings() {
    _getSettings().then(settingsOnNext);
  }

  @override
  void dispose() {}
}
