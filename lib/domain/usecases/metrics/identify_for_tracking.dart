import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';
import '../get_brand.dart';
import '../get_user.dart';

class IdentifyForTrackingUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _getBrand = GetBrandUseCase();
  final _getUser = GetUserUseCase();

  /// Add an artificial delay so we know that the user has been properly
  /// identified before sending other events.
  static const artificialDelay = Duration(seconds: 2);

  Future<void> call() async {
    final user = await _getUser(latest: false);

    assert(user != null);

    return await _metricsRepository.identify(
      user!.uuid,
      _getBrand().identifier,
    ).then((_) => Future.delayed(artificialDelay));
  }
}
