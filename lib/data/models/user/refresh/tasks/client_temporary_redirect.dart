import 'package:vialer/data/models/user/client.dart';
import 'package:vialer/data/models/user/refresh/tasks/voipgrid_user_permissions.dart';

import '../../../../../domain/usecases/business_availability/temporary_redirect/get_current_temporary_redirect.dart';
import '../../../../repositories/voipgrid/user_permissions.dart';
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
