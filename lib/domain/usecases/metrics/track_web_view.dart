import 'dart:async';

import 'package:meta/meta.dart';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class TrackWebViewUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  @override
  Future<void> call({@required String page}) => _metricsRepository.track(
        'web-view',
        {'page': page},
      );
}
