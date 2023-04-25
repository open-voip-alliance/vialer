// ignore_for_file: avoid_types_on_closure_parameters

import '../../../business_availability/temporary_redirect/get_current_temporary_redirect.dart';
import '../../client.dart';
import '../../permissions/user_permissions.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientTemporaryRedirect extends ClientRefreshTaskPerformer {
  const RefreshClientTemporaryRedirect();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final temporaryRedirect = await GetCurrentTemporaryRedirect()();

    return (Client client) => client.copyWith(
          currentTemporaryRedirect: () => temporaryRedirect,
        );
  }

  @override
  bool isPermitted(UserPermissions userPermissions) =>
      userPermissions.canChangeTemporaryRedirect;
}
