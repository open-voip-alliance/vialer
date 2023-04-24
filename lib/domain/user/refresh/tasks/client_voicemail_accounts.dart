// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../dependency_locator.dart';
import '../../../voicemail/voicemail_account_repository.dart';
import '../../client.dart';
import '../../permissions/user_permissions.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientVoicemailAccounts extends ClientRefreshTaskPerformer {
  late final _voicemails = dependencyLocator<VoicemailAccountsRepository>();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final voicemailAccounts = await _voicemails.getVoicemailAccounts(client);

    return (Client client) => client.copyWith(
          voicemailAccounts: () => voicemailAccounts,
        );
  }

  @override
  bool isPermitted(UserPermissions userPermissions) =>
      userPermissions.canViewVoicemailAccounts;
}
