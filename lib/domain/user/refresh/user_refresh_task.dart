import 'tasks/client_available_outgoing_numbers.dart';
import 'tasks/client_opening_hours_modules.dart';
import 'tasks/client_temporary_redirect.dart';
import 'tasks/client_voicemail_accounts.dart';
import 'tasks/client_voip_config.dart';
import 'tasks/previous_session_settings.dart';
import 'tasks/user_destination.dart';
import 'tasks/user_voip_config.dart';
import 'tasks/voipgrid_user_permissions.dart';
import 'tasks/voipgrid_user_settings.dart';
import 'user_refresh_task_performer.dart';

enum UserRefreshTask {
  previousSessionSettings(RefreshPreviousSessionSettings()),
  userVoipConfig(RefreshUserVoipConfig()),
  userDestination(RefreshUserDestination()),
  voipgridUserSettings(RefreshVoipgridUserSettings()),
  voipgridUserPermissions(RefreshVoipgridUserPermissions()),
  clientOutgoingNumbers(RefreshClientAvailableOutgoingNumbers()),
  clientVoicemailAccounts(RefreshClientVoicemailAccounts()),
  clientVoipConfig(RefreshClientVoipConfig()),
  clientTemporaryRedirect(RefreshClientTemporaryRedirect()),
  clientOpeningHoursModules(RefreshClientOpeningHoursModules());

  final UserRefreshTaskPerformer performer;

  const UserRefreshTask(this.performer);

  // Makes more semantic sense when calling for the purpose of including all
  // tasks rather than calling .values.
  static List<UserRefreshTask> get all => UserRefreshTask.values;
}
