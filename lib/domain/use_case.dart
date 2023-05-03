import 'package:recase/recase.dart';

import '../app/util/loggable.dart';
import '../dependency_locator.dart';
import 'metrics/metrics.dart';

abstract class UseCase with Loggable {
  late final _metrics = dependencyLocator<MetricsRepository>();

  /// Track that this Use Case was executed, this will submit it to metrics and
  /// create a log.
  ///
  /// An event name will be generated based on the name of the UseCase.
  ///
  /// e.g. `CreateCustomerUseCase` will become `create-customer`
  ///
  /// @param properties Any properties that should be included when tracking
  /// this Use Case. If not provided, no properties will be tracked.
  void track([Map<String, dynamic>? properties]) {
    final name = runtimeType.toString().replaceAll('UseCase', '').paramCase;

    _metrics.track(name, properties);

    if (properties?.isNotEmpty ?? false) {
      logger.info('[$name] executed with [$properties].');
    } else {
      logger.info('[$name] executed.');
    }
  }
}
