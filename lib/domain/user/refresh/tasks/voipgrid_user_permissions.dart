import 'dart:async';

import 'package:vialer/domain/user/settings/change_setting.dart';

import '../../../../dependency_locator.dart';
import '../../../call_records/client/purge_local_call_records.dart';
import '../../../voipgrid/user_permissions.dart';
import '../../permissions/user_permissions.dart';
import '../../settings/app_setting.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshVoipgridUserPermissions extends UserRefreshTaskPerformer {
  const RefreshVoipgridUserPermissions();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    late final List<UserPermission> granted;

    try {
      granted = await dependencyLocator<UserPermissionsRepository>()
          .getGrantedPermissions(
        user: user,
      );
    } on UnableToRetrievePermissionsException {
      // If we are unable to get the current permissions we should just leave
      // the current permission as it is.
      return unmutatedUser;
    }

    final permissions = granted.toUserPermissions();

    return (User user) => _applyPermissionsSideEffects(permissions, user)
        .copyWith(permissions: permissions);
  }

  User _applyPermissionsSideEffects(
    UserPermissions permissions,
    User user,
  ) {
    if (permissions.canSeeClientCalls) return user;

    unawaited(
      PurgeLocalCallRecordsUseCase()(reason: PurgeReason.permissionFailed),
    );

    var newUser = user;

    // If client calls are enabled, we're going to disable it as the user
    // no longer has permission for it.
    if (user.settings.getOrNull(AppSetting.showClientCalls) == true) {
      ChangeSettingUseCase()(AppSetting.showClientCalls, false);
    }

    return newUser;
  }
}

extension on List<UserPermission> {
  UserPermissions toUserPermissions() => UserPermissions(
        canSeeClientCalls: contains(UserPermission.clientCalls),
        canChangeMobileNumberFallback:
            contains(UserPermission.changeMobileNumberFallback),
        canViewMobileNumberFallbackStatus: contains(UserPermission.viewUser),
        // The only redirect target currently is Voicemail, so if the user
        // cannot view Voicemail they can't use the feature.
        canChangeTemporaryRedirect: contains(UserPermission.viewVoicemail) &&
            contains(UserPermission.temporaryRedirect),
        canViewVoicemailAccounts: contains(UserPermission.viewVoicemail),
        canChangeOutgoingNumber: contains(UserPermission.changeVoipAccount),
        canViewColleagues: contains(UserPermission.listUsers),
        canViewVoipAccounts: contains(UserPermission.listVoipAccounts),
        canViewDialPlans: contains(UserPermission.viewRouting),
        canViewStats: contains(UserPermission.viewStats),
        canChangeOpeningHours: contains(UserPermission.changeOpeningHours),
      );
}
