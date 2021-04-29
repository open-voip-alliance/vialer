import 'package:flutter_phone_lib/call/call.dart';
import 'package:meta/meta.dart';

import '../../../../dependency_locator.dart';
import '../../../repositories/connectivity.dart';
import '../../../repositories/metrics.dart';
import '../../../use_case.dart';

class RateVoipCallUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();
  final _connectivityRepository = dependencyLocator<ConnectivityRepository>();

  @override
  Future<void> call({@required int rating, @required Call call}) async {
    final connectivityType = await _connectivityRepository.currentType;

    _metricsRepository.track('call-rating', {
      'rating': rating,
      'mos': call.mos,
      'duration': call.duration,
      'connection': connectivityType.toString(),
    });
  }
}
