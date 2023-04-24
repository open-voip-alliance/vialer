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
  previousSessionSettings,
  userVoipConfig,
  userDestination,
  voipgridUserSettings,
  voipgridUserPermissions,
  clientOutgoingNumbers,
  clientVoicemailAccounts,
  clientVoipConfig,
  clientTemporaryRedirect,
  clientOpeningHoursModules;

  // Makes more semantic sense when calling for the purpose of including all
  // tasks rather than calling .values.
  static List<UserRefreshTask> get all => UserRefreshTask.values;

  UserRefreshTaskPerformer get performer {
    // Implemented as a switch rather than map to ensure compile-time safety.
    switch (this) {
      case UserRefreshTask.previousSessionSettings:
        return RefreshPreviousSessionSettings();
      case UserRefreshTask.voipgridUserPermissions:
        return RefreshVoipgridUserPermissions();
      case UserRefreshTask.clientOutgoingNumbers:
        return RefreshClientAvailableOutgoingNumbers();
      case UserRefreshTask.clientVoicemailAccounts:
        return RefreshClientVoicemailAccounts();
      case UserRefreshTask.userVoipConfig:
        return RefreshUserVoipConfig();
      case UserRefreshTask.clientVoipConfig:
        return RefreshClientVoipConfig();
      case UserRefreshTask.clientTemporaryRedirect:
        return RefreshClientTemporaryRedirect();
      case UserRefreshTask.userDestination:
        return RefreshUserDestination();
      case UserRefreshTask.voipgridUserSettings:
        return RefreshVoipgridUserSettings();
      case UserRefreshTask.clientOpeningHoursModules:
        return RefreshClientOpeningHoursModules();
    }
  }
}
