import '../../../../dependency_locator.dart';
import '../../../authentication/authentication_repository.dart';
import '../../permissions/user_permissions.dart';
import '../../settings/call_setting.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

/// Refreshes settings stored against the logged-in VoIPGRID user, these are the
/// type of settings that would be visible in the portal.
class RefreshVoipgridUserSettings extends SettingsRefreshTaskPerformer {
  const RefreshVoipgridUserSettings();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User user) async {
    final useMobileNumberAsFallback = await dependencyLocator<AuthRepository>()
        .isUserUsingMobileNumberAsFallback(user);

    return (User user) => (
          CallSetting.useMobileNumberAsFallback,
          useMobileNumberAsFallback,
        );
  }

  @override
  bool isPermitted(UserPermissions userPermissions) =>
      userPermissions.canViewMobileNumberFallbackStatus;
}
