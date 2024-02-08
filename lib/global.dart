import 'package:vialer/dependency_locator.dart';

import 'data/repositories/metrics/metrics.dart';

// This file will contain a limited amount of global helper functions, these
// should mainly be reserved for developer-level interactions rather than
// business logic. For example, logging is not business logic and therefore
// should not require dependencies.

/// Track an event, if there is no [MetricsRepository] registered, the event
/// will be ignored.
void track(String eventName, [Map<String, dynamic>? properties]) =>
    dependencyLocator.isRegistered<MetricsRepository>()
        ? dependencyLocator<MetricsRepository>().track(eventName, properties)
        : null;
