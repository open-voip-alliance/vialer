import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/call_repository.dart';
import '../../../../../domain/usecases/call.dart';

class DialerPresenter extends Presenter {
  Function callOnComplete;

  final CallUseCase _callUseCase;

  DialerPresenter(CallRepository callRepository)
      : _callUseCase = CallUseCase(callRepository);

  void call(String destination) {
    _callUseCase.execute(
      _CallUseCaseObserver(this),
      CallUseCaseParams(destination),
    );
  }

  @override
  void dispose() {
    _callUseCase.dispose();
  }
}

class _CallUseCaseObserver extends Observer<void> {
  final DialerPresenter presenter;

  _CallUseCaseObserver(this.presenter);

  @override
  void onComplete() => presenter.callOnComplete;

  @override
  void onError(dynamic e) {}

  @override
  void onNext(_) {}
}
