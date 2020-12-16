import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';

/// Note: Survey will not be sent in debug mode!
class SendSurveyResultsUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  // TODO: Use proper type for data.
  @override
  Future<void> call({@required Map<String, dynamic> data}) =>
      _metricsRepository.track('survey', data);
}
