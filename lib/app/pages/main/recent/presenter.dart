import 'package:meta/meta.dart';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/usecases/call.dart';

import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/usecases/get_recent_calls.dart';

import '../../../../domain/repositories/setting.dart';
import '../../../../domain/usecases/get_settings.dart';

import '../util/observer.dart';

class RecentPresenter extends Presenter {
  Function recentCallsOnNext;

  Function callOnError;

  Function settingsOnNext;

  final GetRecentCallsUseCase _getRecentCallsUseCase;
  final CallUseCase _callUseCase;
  final GetSettingsUseCase _getSettingsUseCase;

  RecentPresenter(
    RecentCallRepository recentCallRepository,
    CallRepository callRepository,
    SettingRepository settingRepository,
  )   : _getRecentCallsUseCase = GetRecentCallsUseCase(recentCallRepository),
        _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _callUseCase = CallUseCase(callRepository);

  void getRecentCalls({@required int page}) {
    _getRecentCallsUseCase.execute(
      Watcher(
        onNext: recentCallsOnNext,
      ),
      GetRecentCallsUseCaseParams(
        page: page,
      ),
    );
  }

  void call(String destination) => _callUseCase.execute(
        Watcher(
          onError: (e) => callOnError(e),
        ),
        CallUseCaseParams(destination),
      );

  void getSettings() {
    _getSettingsUseCase.execute(
      Watcher(onNext: settingsOnNext),
    );
  }

  @override
  void dispose() {
    _getRecentCallsUseCase.dispose();
  }
}
