import 'package:vialer/domain/user/refresh/tasks/voipgrid_user_permissions.dart';

import '../../../business_availability/temporary_redirect/get_current_temporary_redirect.dart';
import '../../../voipgrid/user_permissions.dart';
import '../../client.dart';
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
  bool isPermitted(Permissions permissions) =>
      permissions.contains(Permission.canChangeTemporaryRedirect);
}
