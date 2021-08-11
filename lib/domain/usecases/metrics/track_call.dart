import 'dart:async';

import 'package:flutter_phone_lib/flutter_phone_lib.dart';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required String via,
    required bool voip,
    required CallDirection direction,
  }) =>
      _metricsRepository.track('call', {
        'via': via,
        'voip': voip,
        'direction':
            direction == CallDirection.inbound ? 'inbound' : 'outbound',
      });
}
