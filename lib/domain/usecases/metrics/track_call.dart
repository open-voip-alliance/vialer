import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackCallUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  Future<void> call({
    @required String via,
    @required bool voip,
  }) =>
      _metricsRepository.track(
        'call',
        {
          'via': via,
          'voip': voip,
        },
      );
}
