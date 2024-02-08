import 'dart:async';
import 'dart:io';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../data/repositories/env.dart';
import '../../../dependency_locator.dart';
import '../../../presentation/util/pigeon.dart';
import '../use_case.dart';

class InitializeMetricCollection extends UseCase {
  late final _envRepository = dependencyLocator<EnvRepository>();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _nativeMetrics = NativeMetrics();

  Future<void> call() async {
    final key = Platform.isAndroid
        ? _envRepository.segmentAndroidKey
        : _envRepository.segmentIosKey;

    unawaited(_nativeMetrics.initialize());

    await _metricsRepository.initialize(key);
  }
}
