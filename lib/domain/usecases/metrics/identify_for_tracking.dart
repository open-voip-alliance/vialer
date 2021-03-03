import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';
import '../get_brand.dart';
import '../get_user.dart';

class IdentifyForTrackingUseCase extends FutureUseCase<void> {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _getBrand = GetBrandUseCase();
  final _getUser = GetUserUseCase();

  @override
  Future<void> call() async {
    final user = await _getUser(latest: false);

    assert(user != null);
    await _metricsRepository.identify(
      user.uuid,
      _getBrand().identifier,
    );
  }
}
