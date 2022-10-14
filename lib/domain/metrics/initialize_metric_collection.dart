import 'dart:async';
import 'dart:io';

import '../../app/util/pigeon.dart';
import '../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';
import 'metrics.dart';

class InitializeMetricCollection extends UseCase {
  final _envRepository = dependencyLocator<EnvRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _nativeMetrics = NativeMetrics();

  Future<void> call() async {
    final key = await (Platform.isAndroid
        ? _envRepository.segmentAndroidKey
        : _envRepository.segmentIosKey);

    _nativeMetrics.initialize();

    await _metricsRepository.initialize(key);
  }
}
