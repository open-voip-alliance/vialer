import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/selected_destination_info.dart';
import '../entities/setting.dart';
import '../entities/system_user.dart';
import '../repositories/destination.dart';
import '../repositories/metrics.dart';
import '../use_case.dart';
import 'get_user.dart';

class ChangeAvailabilityUseCase extends UseCase {
  final _getUser = GetUserUseCase();
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<AvailabilitySetting> call({
    required SelectedDestinationInfo destination,
  }) async {
    final user = await _getUser(latest: false);

    await _destinationRepository.setAvailability(
      selectedDestinationId: destination.id,
      phoneAccountId: destination.phoneAccountId,
      fixedDestinationId: destination.fixedDestinationId,
    );

    _metricsRepository.track('destination-changed', {
      'has-app-account': user.hasAppAccount,
      'to-fixed-destination': destination.fixedDestinationId != null,
      'to-phone-account': destination.phoneAccountId != null,
    });

    return AvailabilitySetting(
      await _destinationRepository.getLatestAvailability(),
    );
  }
}

extension on SystemUser? {
  bool get hasAppAccount => this != null && this?.appAccountUrl != null;
}
