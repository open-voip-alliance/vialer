import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../repositories/call.dart';

class CallUseCase extends UseCase<void, CallUseCaseParams> {
  final CallRepository _callRepository;

  CallUseCase(this._callRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(CallUseCaseParams params) async {
    final controller = StreamController<bool>();

    await _callRepository.call(params.destination);

    unawaited(controller.close());

    return controller.stream;
  }
}

class CallUseCaseParams {
  final String destination;

  CallUseCaseParams(this.destination);
}
