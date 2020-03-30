import 'package:meta/meta.dart';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/call.dart';
import '../../../../domain/repositories/recent_call.dart';
import '../../../../domain/usecases/get_recent_calls.dart';

class RecentPresenter extends Presenter {
  Function recentCallsOnNext;

  final GetRecentCallsUseCase _getRecentCallsUseCase;

  RecentPresenter(RecentCallRepository recentCallRepository)
      : _getRecentCallsUseCase = GetRecentCallsUseCase(recentCallRepository);

  void getRecentCalls({@required int page}) {
    _getRecentCallsUseCase.execute(
      _GetRecentCallsUseCaseObserver(this),
      GetRecentCallsUseCaseParams(
        page: page,
      ),
    );
  }

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
