import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/voip.dart';
import '../use_case.dart';

class SendVoipDtmfUseCase extends FutureUseCase<void> {
  final _voipRepository = dependencyLocator<VoipRepository>();

  @override
  Future<void> call({@required String dtmf}) => _voipRepository.sendDtmf(dtmf);
}
