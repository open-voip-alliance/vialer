import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/voip.dart';
import '../../../use_case.dart';

class GetCallSessionState extends UseCase {
  final _voipRepository = dependencyLocator<VoipRepository>();

  Future<CallSessionState> call() => _voipRepository.sessionState;
}
