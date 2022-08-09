import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../entities/voipgrid_permissions.dart';
import '../repositories/voipgrid_permissions.dart';
import '../use_case.dart';
import 'change_setting.dart';
import 'get_setting.dart';

class GetLatestVoipgridPermissions extends UseCase {
  final _vgPermissions = dependencyLocator<VoipgridPermissionsRepository>();
  final _changeSetting = ChangeSettingUseCase();

  Future<VoipgridPermissions> call() async {
    final clientCallsVgPermission = await _vgPermissions.hasPermission(
      type: VoipgridPermission.clientCalls,
    );

    // If we are unable to get the current permissions we should just leave
    // the current permission as it is.
    if (clientCallsVgPermission == PermissionResult.unavailable) {
      return (await GetSettingUseCase<VoipgridPermissionsSetting>()()).value;
    }

    final permissions = VoipgridPermissions(
      hasClientCallsPermission:
          clientCallsVgPermission == PermissionResult.granted,
    );

    await _changeSetting(setting: VoipgridPermissionsSetting(permissions));

    // If a user loses permission we want to disable this setting.
    if (!permissions.hasClientCallsPermission) {
      final showClientCalls =
          await GetSettingUseCase<ShowClientCallsSetting>()();

      if (showClientCalls.value) {
        await _changeSetting(setting: const ShowClientCallsSetting(false));
      }
    }

    return permissions;
  }
}
