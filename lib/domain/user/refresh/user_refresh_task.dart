import 'package:vialer/domain/user/refresh/tasks/user_details.dart';
import 'package:vialer/domain/user/refresh/tasks/user_availability_status.dart';
import 'package:vialer/domain/user/refresh/tasks/user_has_feature_announcements.dart';

import 'tasks/client_available_outgoing_numbers.dart';
import 'tasks/client_opening_hours_modules.dart';
import 'tasks/client_temporary_redirect.dart';
import 'tasks/client_voicemail_accounts.dart';
import 'tasks/client_voip_config.dart';
import 'tasks/app_account.dart';
import 'tasks/voipgrid_user_permissions.dart';
import 'user_refresh_task_performer.dart';

enum UserRefreshTask {
  userCore(null),
  appAccount(RefreshAppAccount()),
  userAvailabilityStatus(RefreshUserAvailabilityStatus()),
  voipgridUserPermissions(RefreshVoipgridUserPermissions()),
  clientOutgoingNumbers(RefreshClientAvailableOutgoingNumbers()),
  clientVoicemailAccounts(RefreshClientVoicemailAccounts()),
  clientVoipConfig(RefreshClientVoipConfig()),
  clientTemporaryRedirect(RefreshClientTemporaryRedirect()),
  clientOpeningHoursModules(RefreshClientOpeningHoursModules()),
  userHasFeatureAnnouncements(RefreshUserHasUnreadFeatureAnnouncements()),
  userDetails(RefreshUserDetails());

  const UserRefreshTask(this.performer);

  final UserRefreshTaskPerformer? performer;

  // Makes more semantic sense when calling for the purpose of including all
  // tasks rather than calling .values.
  static List<UserRefreshTask> get all => UserRefreshTask.values;

  /// A minimal set of tasks that can be run regularly, will not include
  /// anything that is unlikely to be updated regularly.
  static List<UserRefreshTask> get minimal => [
        UserRefreshTask.userCore,
        UserRefreshTask.userDetails,
        UserRefreshTask.userAvailabilityStatus,
        UserRefreshTask.clientTemporaryRedirect,
        UserRefreshTask.userHasFeatureAnnouncements,
      ];
}
