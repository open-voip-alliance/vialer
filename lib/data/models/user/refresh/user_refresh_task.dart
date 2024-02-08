import 'package:vialer/data/models/user/refresh/tasks/app_account.dart';
import 'package:vialer/data/models/user/refresh/tasks/client_available_outgoing_numbers.dart';
import 'package:vialer/data/models/user/refresh/tasks/client_opening_hours_modules.dart';
import 'package:vialer/data/models/user/refresh/tasks/client_temporary_redirect.dart';
import 'package:vialer/data/models/user/refresh/tasks/client_voicemail_accounts.dart';
import 'package:vialer/data/models/user/refresh/tasks/client_voip_config.dart';
import 'package:vialer/data/models/user/refresh/tasks/user_details.dart';
import 'package:vialer/data/models/user/refresh/tasks/user_has_feature_announcements.dart';
import 'package:vialer/data/models/user/refresh/tasks/voipgrid_user_permissions.dart';
import 'package:vialer/data/models/user/refresh/user_refresh_task_performer.dart';

enum UserRefreshTask {
  userCore(null),
  appAccount(RefreshAppAccount()),
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
        UserRefreshTask.clientTemporaryRedirect,
        UserRefreshTask.userHasFeatureAnnouncements,
      ];
}
