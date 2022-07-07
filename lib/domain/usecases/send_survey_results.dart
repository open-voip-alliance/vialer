import 'dart:async';

import 'package:dartx/dartx.dart';

import '../../dependency_locator.dart';
import '../entities/survey/survey.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';

/// Note: Survey will not be sent in debug mode!
class SendSurveyResultsUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  // TODO: Use proper type for data.
  Future<void> call(SurveyId id, {required Map<String, dynamic> data}) =>
      _metricsRepository.track('${id.eventName}-survey', data);
}


extension on SurveyId {
  /// Changes e.g. `appRating` to `app-rating`.
  String get eventName {
    return name.characters.map((c) => c.isUpperCase ? '-$c' : c).join();
  }
}