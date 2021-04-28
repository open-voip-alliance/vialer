import 'package:flutter_phone_lib/call/call.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/connectivity.dart';
import '../../../repositories/metrics.dart';
import '../../../use_case.dart';

class RateVoipCallUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  Future<void> call({required int rating, required Call call}) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('call-rating', {
      'rating': rating,
      'mos': call.mos,
      'duration': call.duration,
      'connection': connectivityType.toString(),
    });
  }
}
