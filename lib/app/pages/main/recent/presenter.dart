import 'package:meta/meta.dart';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/usecases/call.dart';

import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/usecases/get_recent_calls.dart';

import '../util/observer.dart';

class RecentPresenter extends Presenter {
  Function recentCallsOnNext;

  Function callOnError;

  final GetRecentCallsUseCase _getRecentCallsUseCase;
  final CallUseCase _callUseCase;

  RecentPresenter(
    RecentCallRepository recentCallRepository,
    CallRepository callRepository,
  )   : _getRecentCallsUseCase = GetRecentCallsUseCase(recentCallRepository),
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

  @override
  void dispose() {
    _getRecentCallsUseCase.dispose();
  }
}
