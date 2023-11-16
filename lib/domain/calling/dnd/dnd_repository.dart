import 'package:injectable/injectable.dart';
import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/calling/dnd/dnd_service.dart';
import 'package:vialer/domain/user/user.dart';

import '../../relations/colleagues/colleague.dart';

@injectable
class DndRepository with Loggable {
  DndRepository(this._service);

  final DndService _service;

  Future<DndStatus> getDndStatus(User user) async {
    final response = await _service.getDndStatus(
      clientUuid: user.client.uuid,
      userUuid: user.uuid,
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get Dnd Status');
      throw Exception('Unable to get dnd status from the api');
    }

    final status = response.body!['status'];

    // Relations are doing some work to make their use of constants consistent,
    // this means we will need to temporarily accept both versions. This can
    // be changed to only accept the snake-case in a future release.
    return DndStatus.fromBool(
      ['DND', 'do_not_disturb'].contains(status),
    );
  }

  Future<void> changeDndStatus(User user, DndStatus dndStatus) =>
      _service.changeDndStatus(
        {
          // Relating to the comments mentioned above, the back-end will
          // accept both caps and snake-case versions for a while after the
          // changes have been deployed. This should also be changed to submit
          // snake-case in a future release.
          'status': dndStatus.asBool() ? 'DND' : 'AVAILABLE',
        },
        clientUuid: user.client.uuid,
        userUuid: user.uuid,
      );
}

enum DndStatus {
  doNotDisturbOn,
  doNotDisturbOff;

  bool asBool() => this == DndStatus.doNotDisturbOn;
  ColleagueAvailabilityStatus? asAvailabilityStatus() =>
      this == DndStatus.doNotDisturbOn
          ? ColleagueAvailabilityStatus.doNotDisturb
          : null;
  static DndStatus fromBool(bool value) =>
      value ? DndStatus.doNotDisturbOn : DndStatus.doNotDisturbOff;
}
