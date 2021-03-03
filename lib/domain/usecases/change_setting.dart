import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/destination.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'disable_remote_logging.dart';
import 'enable_remote_logging.dart';
import 'get_settings.dart';

class ChangeSettingUseCase extends FutureUseCase<void> {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _destinationRepository = dependencyLocator<DestinationRepository>();

  final _getSettings = GetSettingsUseCase();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();
  final _disableRemoteLogging = DisableRemoteLoggingUseCase();

  @override
  Future<void> call({@required Setting setting, bool remote = true}) async {
    if (setting is RemoteLoggingSetting) {
      if (setting.value) {
        await _enableRemoteLogging();
      } else {
        await _disableRemoteLogging();
      }
    } else if (remote && setting is AvailabilitySetting) {
      var availability = (setting as AvailabilitySetting).value;
      await _destinationRepository.setAvailability(
        selectedDestinationId: availability.selectedDestinationInfo.id,
        phoneAccountId: availability.selectedDestinationInfo.phoneAccountId,
        fixedDestinationId:
            availability.selectedDestinationInfo.fixedDestinationId,
      );

      availability = await _destinationRepository.getLatestAvailability();
      setting = AvailabilitySetting(availability);
    }

    if (!setting.mutable) {
      throw UnsupportedError(
        'Vialer error: Unsupported operation: '
        'Don\'t save an immutable setting.',
      );
    }

    final settings = await _getSettings();

    final newSettings = List<Setting>.from(settings)
      ..removeWhere((e) => e.runtimeType == setting.runtimeType)
      ..add(setting);

    // We only want to save mutable settings.
    _storageRepository.settings = newSettings.where((s) => s.mutable).toList();
  }
}
