import 'dart:async';

import '../../dependency_locator.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';

/// Note: Survey will not be sent in debug mode!
class SendSurveyResultsUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  // TODO: Use proper type for data.
  Future<void> call({required Map<String, dynamic> data}) =>
      _metricsRepository.track('survey', data);
}
