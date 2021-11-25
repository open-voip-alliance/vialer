import 'dart:async';
import 'dart:io';

import '../../dependency_locator.dart';
import '../repositories/env.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';

class InitializeMetricCollection extends UseCase {
  final _envRepository = dependencyLocator<EnvRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call() async {
    final key = await (Platform.isAndroid
        ? _envRepository.segmentAndroidKey
        : _envRepository.segmentIosKey);

    await _metricsRepository.initialize(key);
  }
}
