// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../dependency_locator.dart';
import '../../../calling/voip/destination_repository.dart';
import '../../settings/call_setting.dart';
import '../../settings/settings.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshUserDestination extends SettingsRefreshTaskPerformer {
  late final _destinationRepository =
      dependencyLocator<DestinationRepository>();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User _) async {
    final destination = await _destinationRepository.getActiveDestination();

    return (Settings settings) => settings.copyWithAll(
          destination.maybeWhen(
            unknown: () => const {},
            orElse: () => {CallSetting.destination: destination},
          ),
        );
  }
}
