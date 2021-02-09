import 'dart:async';

import 'package:voip_flutter_integration/voip_flutter_integration.dart';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class GetActiveCall extends FutureUseCase<FilCall> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Future<FilCall> call() => _voipRepository.activeCall;
}
