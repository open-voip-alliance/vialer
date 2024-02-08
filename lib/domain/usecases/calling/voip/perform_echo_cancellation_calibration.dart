import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../data/repositories/calling/voip/voip.dart';
import '../../../../dependency_locator.dart';
import '../../../../presentation/util/loggable.dart';
import '../../use_case.dart';

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
      _metricsRepository.track('echo-cancellation-calibration-performed');
}
