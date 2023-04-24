// ignore_for_file: avoid_types_on_closure_parameters

import '../../../openings_hours_basic/get_opening_hours_modules.dart';
import '../../client.dart';
import '../../permissions/user_permissions.dart';
import '../user_refresh_task_performer.dart';

class RefreshClientOpeningHoursModules extends ClientRefreshTaskPerformer {
  late final _getOpeningHoursModules = GetOpeningHoursModules();

  @override
  Future<ClientMutator> performClientRefreshTask(Client client) async {
    final openingHours = await _getOpeningHoursModules();

    return (Client client) => client.copyWith(
          openingHoursModules: () => openingHours,
        );
  }

  @override
  bool isPermitted(UserPermissions userPermissions) =>
      userPermissions.canChangeOpeningHours;
}
