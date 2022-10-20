import 'dart:async';

import '../../../dependency_locator.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';
import '../get_brand.dart';
import '../get_logged_in_user.dart';

class IdentifyForTrackingUseCase extends UseCase {
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _getBrand = GetBrandUseCase();
  final _getUser = GetLoggedInUserUseCase();

  /// Add an artificial delay so we know that the user has been properly
  /// identified before sending other events.
  static const _artificialDelay = Duration(seconds: 2);

  Future<void> call() async {
    return await _metricsRepository
        .identify(
          _getUser().uuid,
          _getBrand().identifier,
        )
        .then((_) => Future.delayed(_artificialDelay));
  }
}
