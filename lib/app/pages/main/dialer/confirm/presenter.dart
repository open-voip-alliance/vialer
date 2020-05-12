import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/repositories/call.dart';
import '../../../../../domain/usecases/call.dart';

import '../../util/observer.dart';

class DialerPresenter extends Presenter {
  Function callOnComplete;

  final CallUseCase _callUseCase;

  DialerPresenter(CallRepository callRepository)
      : _callUseCase = CallUseCase(callRepository);

  void call(String destination) {
    _callUseCase.execute(
      Watcher(
        onComplete: callOnComplete,
      ),
      CallUseCaseParams(destination),
    );
  }

  @override
  void dispose() {
    _callUseCase.dispose();
  }
}
