import 'package:vialer/data/models/user/client.dart';
import 'package:vialer/data/models/user/refresh/tasks/voipgrid_user_permissions.dart';

import '../../../../../domain/usecases/opening_hours_basic/get_opening_hours_modules.dart';
import '../../../../repositories/voipgrid/user_permissions.dart';
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
