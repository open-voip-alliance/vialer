import '../../data/models/colltact.dart';
import '../../dependency_locator.dart';
import '../use_case.dart';
import 'metrics.dart';

class TrackT9Usage extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call(Colltact colltact) async => _metricsRepository.track(
        'contact-t9-selected',
        {
          'type': colltact.when(
            colleague: (_) => 'colleague',
            contact: (_) => 'contact',
          ),
        },
      );
}
