import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import 'voip.dart';

class PerformEchoCancellationCalibrationUseCase extends UseCase with Loggable {
  final _voipRepository = dependencyLocator<VoipRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call() async {
    logger.info('Performing echo cancellation calibration');

    return _voipRepository
        .performEchoCancellationCalibration()
        .then((_) => _track());
  }

  void _track() =>
      _metricsRepository.track('performed-echo-cancellation-calibration');
}
