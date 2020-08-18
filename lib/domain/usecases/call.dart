import 'dart:async';

import 'package:meta/meta.dart';

import '../use_case.dart';
import '../repositories/call.dart';

class CallUseCase extends FutureUseCase<void> {
  final CallRepository _callRepository;

  CallUseCase(this._callRepository);

  @override
  Future<void> call({@required String destination}) =>
      _callRepository.call(destination);
}
