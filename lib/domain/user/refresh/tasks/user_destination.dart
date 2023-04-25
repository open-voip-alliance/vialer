// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../dependency_locator.dart';
import '../../../calling/voip/destination_repository.dart';
import '../../settings/call_setting.dart';
import '../../settings/settings.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshUserDestination extends SettingsRefreshTaskPerformer {
  const RefreshUserDestination();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User _) async {
    final destination =
        await dependencyLocator<DestinationRepository>().getActiveDestination();

    return (Settings settings) => settings.copyWithAll(
          destination.maybeWhen(
            unknown: () => const {},
            orElse: () => {CallSetting.destination: destination},
          ),
        );
  }
}
