import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/destination.dart';
import '../repositories/logging.dart';
import '../repositories/setting.dart';
import '../use_case.dart';

class ChangeSettingUseCase extends FutureUseCase<void> {
  final _settingRepository = dependencyLocator<SettingRepository>();
  final _loggingRepository = dependencyLocator<LoggingRepository>();
  final _destinationRepository = dependencyLocator<DestinationRepository>();

  @override
  Future<void> call({@required Setting setting, bool remote = true}) async {
    if (setting is RemoteLoggingSetting) {
      if (setting.value) {
        await _loggingRepository.enableRemoteLogging();
      } else {
        await _loggingRepository.disableRemoteLogging();
      }
    } else if (remote && setting is AvailabilitySetting) {
      var availability = (setting as AvailabilitySetting).value;
      await _destinationRepository.setAvailability(
        selectedDestinationId: availability.selectedDestination.id,
        phoneAccountId: availability.selectedDestination.phoneAccountId,
        fixedDestinationId: availability.selectedDestination.fixedDestinationId,
      );

      availability = await _destinationRepository.getLatestAvailability();
      setting = AvailabilitySetting(availability);
    }

    await _settingRepository.changeSetting(setting);
  }
}
