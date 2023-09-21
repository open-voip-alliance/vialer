import 'package:vialer/domain/user/refresh/tasks/voipgrid_user_permissions.dart';

import '../../../openings_hours_basic/get_opening_hours_modules.dart';
import '../../../voipgrid/user_permissions.dart';
import '../../client.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientOpeningHoursModules extends ClientRefreshTaskPerformer {
  const RefreshClientOpeningHoursModules();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final openingHours = await GetOpeningHoursModules()();

    return (Client client) => client.copyWith(
          openingHoursModules: () => openingHours,
        );
  }

  @override
  bool isPermitted(Permissions permissions) =>
      permissions.contains(Permission.canChangeOpeningHours);
}
