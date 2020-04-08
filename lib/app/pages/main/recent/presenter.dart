import 'package:meta/meta.dart';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/repositories/call.dart';
import '../../../../domain/usecases/call.dart';

import '../../../../domain/entities/call.dart';
import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/usecases/get_recent_calls.dart';

class RecentPresenter extends Presenter {
  Function recentCallsOnNext;

  final GetRecentCallsUseCase _getRecentCallsUseCase;
  final CallUseCase _callUseCase;

  RecentPresenter(
    RecentCallRepository recentCallRepository,
    CallRepository callRepository,
  )   : _getRecentCallsUseCase = GetRecentCallsUseCase(recentCallRepository),
        _callUseCase = CallUseCase(callRepository);

  void getRecentCalls({@required int page}) {
    _getRecentCallsUseCase.execute(
      _GetRecentCallsUseCaseObserver(this),
      GetRecentCallsUseCaseParams(
        page: page,
      ),
    );
  }

  void call(String destination) => _callUseCase.execute(
        _GetCallUseCaseObserver(this),
        CallUseCaseParams(destination),
      );

  @override
  void dispose() {
    _getRecentCallsUseCase.dispose();
  }
}

class _GetRecentCallsUseCaseObserver extends Observer<List<Call>> {
  final RecentPresenter presenter;

  _GetRecentCallsUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(List<Call> recentCalls) =>
      presenter.recentCallsOnNext(recentCalls);
}

class _GetCallUseCaseObserver extends Observer<void> {
  final RecentPresenter presenter;

  _GetCallUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(_) {}

  @override
  void onNext(_) {}
}
