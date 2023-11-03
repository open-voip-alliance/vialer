import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/calling/dnd/dnd_service.dart';
import 'package:vialer/domain/user/user.dart';

import '../../relations/colleagues/colleague.dart';

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

    return DndStatus.fromBool(response.body!['status'] == 'DND');
  }

  Future<void> changeDndStatus(User user, DndStatus dndStatus) =>
      _service.changeDndStatus(
        {
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
