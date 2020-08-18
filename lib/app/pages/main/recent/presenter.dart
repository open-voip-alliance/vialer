import 'package:meta/meta.dart';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/call.dart';
import '../../../../domain/usecases/get_recent_calls.dart';
import '../../../../domain/usecases/get_settings.dart';

class RecentPresenter extends Presenter {
  Function recentCallsOnNext;
  Function recentCallsOnError;

  Function callOnError;

  Function settingsOnNext;

  final _getRecentCalls = GetRecentCallsUseCase();
  final _call = CallUseCase();
  final _getSettings = GetSettingsUseCase();

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
