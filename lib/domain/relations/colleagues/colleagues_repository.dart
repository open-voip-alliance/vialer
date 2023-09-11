import 'dart:async';

import 'package:dartx/dartx.dart';

import '../../../app/util/loggable.dart';
import '../../user/user.dart';
import '../../voipgrid/voipgrid_api_resource_collector.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'colleague.dart';

class ColleaguesRepository with Loggable {
  ColleaguesRepository(
    this._service,
    this._apiResourceCollector,
  );

  final VoipgridService _service;
  final VoipgridApiResourceCollector _apiResourceCollector;

  /// This only provides the most basic information about colleagues,
  /// the rest needs to be queried by calling [startListeningForAvailability]
  /// and listening for updates.
  Future<List<Colleague>> getColleagues(User user) async {
    final clientId = user.client.id.toString();

    final users = user.permissions.canViewColleagues
        ? await _apiResourceCollector.collect(
            requester: (page) => _service.getUsers(
              clientId,
              page: page,
            ),
            deserializer: (json) => json,
          )
        : const <Map<String, dynamic>>[];

    final voipAccounts = user.permissions.canViewVoipAccounts
        ? await _apiResourceCollector.collect(
            requester: (page) => _service.getUnconnectedVoipAccounts(
              clientId,
              page: page,
            ),
            deserializer: (json) => json,
          )
        : const <Map<String, dynamic>>[];

    return [
      ...users.map(
        (e) => Colleague(
          id: e['id'] as String,
          name: e['name'] as String,
          context: [],
        ),
      ),
      ...voipAccounts.map(
        (e) => Colleague.unconnectedVoipAccount(
          id: e['id'] as String,
          name: e['description'] as String,
          number: e['internal_number'] as String,
        ),
      ),
    ].without(user: user);
  }
}

extension on List<Colleague> {
  /// Removes any users that match the provided user, this is used to remove
  /// the logged in user from the list of colleagues.
  List<Colleague> without({required User user}) =>
      filter((colleague) => colleague.id != user.uuid).toList();
}
