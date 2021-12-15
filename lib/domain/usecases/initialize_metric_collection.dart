import 'dart:async';
import 'dart:io';

import '../../app/util/pigeon.dart';

import '../../dependency_locator.dart';
import '../repositories/env.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';

class InitializeMetricCollection extends UseCase {
  final _envRepository = dependencyLocator<EnvRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _nativeMetrics = NativeMetrics();

  Future<void> call() async {
    final key = await (Platform.isAndroid
        ? _envRepository.segmentAndroidKey
        : _envRepository.segmentIosKey);

    _nativeMetrics.initialize(key);

    await _metricsRepository.initialize(key);
  }
}
