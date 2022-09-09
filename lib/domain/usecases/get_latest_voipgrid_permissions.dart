import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../entities/voipgrid_permissions.dart';
import '../repositories/voipgrid_permissions.dart';
import '../use_case.dart';
import 'change_setting.dart';
import 'client_calls/purge_local_call_records.dart';
import 'get_setting.dart';
import 'get_user.dart';

class GetLatestVoipgridPermissions extends UseCase {
  final _vgPermissions = dependencyLocator<VoipgridPermissionsRepository>();
  final _changeSetting = ChangeSettingUseCase();
  final _purgeLocalCallRecords = PurgeLocalCallRecords();
  final _getUser = GetUserUseCase();

  Future<VoipgridPermissions> call() async {
    final user = (await _getUser(latest: false))!;

    final clientCallsVgPermission = await _vgPermissions.hasPermission(
      type: VoipgridPermission.clientCalls,
      user: user,
    );

    final mobileNumberFallbackPermission = await _vgPermissions.hasPermission(
      type: VoipgridPermission.mobileNumberFallback,
      user: user,
    );

    // If we are unable to get the current permissions we should just leave
    // the current permission as it is.
    if (clientCallsVgPermission == PermissionResult.unavailable ||
        mobileNumberFallbackPermission == PermissionResult.unavailable) {
      return (await GetSettingUseCase<VoipgridPermissionsSetting>()()).value;
    }

    final permissions = VoipgridPermissions(
      hasClientCallsPermission:
          clientCallsVgPermission == PermissionResult.granted,
      hasMobileNumberFallbackPermission:
          mobileNumberFallbackPermission == PermissionResult.granted,
    );

    if (!permissions.hasClientCallsPermission) {
      _purgeLocalCallRecords(reason: PurgeReason.permissionFailed);
    }

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
