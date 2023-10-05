import 'package:vialer/domain/user/refresh/tasks/voipgrid_user_permissions.dart';

import '../../../../dependency_locator.dart';
import '../../../voicemail/voicemail_account_repository.dart';
import '../../../voipgrid/user_permissions.dart';
import '../../client.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientVoicemailAccounts extends ClientRefreshTaskPerformer {
  const RefreshClientVoicemailAccounts();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final voicemailAccounts =
        await dependencyLocator<VoicemailAccountsRepository>()
            .getVoicemailAccounts(client);

    return (Client client) => client.copyWith(
          voicemailAccounts: () => voicemailAccounts,
        );
  }

  @override
  bool isPermitted(Permissions permissions) =>
      permissions.contains(Permission.canViewVoicemailAccounts);
}
