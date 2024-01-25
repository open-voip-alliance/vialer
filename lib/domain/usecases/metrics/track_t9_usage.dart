import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../data/models/colltacts/colltact.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class TrackT9Usage extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call(Colltact colltact) async => _metricsRepository.track(
        'contact-t9-selected',
        {
          'type': switch (colltact) {
            ColltactColleague() => 'colleague',
            ColltactContact() => 'contact',
            ColltactSharedContact() => 'sharedContact',
          },
        },
      );
}
