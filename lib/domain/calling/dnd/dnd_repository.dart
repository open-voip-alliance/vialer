import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/calling/dnd/dnd_service.dart';
import 'package:vialer/domain/user/user.dart';
import 'package:vialer/domain/user_availability/colleagues/colleague.dart';

class DndRepository with Loggable {
  DndRepository(this._service);

  final DndService _service;

  Future<DndStatus> getDndStatus(User user) async {
    final response = await _service.getDndStatus(
      clientUuid: user.client.uuid,
      userUuid: user.uuid,
    );

    if (response.statusCode == 404) {
      return DndStatus.doNotDisturbOff;
    }

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get Dnd Status');
      return DndStatus.doNotDisturbOff;
    }

    return DndStatus.fromBool(response.body!['dnd'] as bool);
  }

  Future<void> changeDndStatus(User user, DndStatus dndStatus) =>
      _service.changeDndStatus(
        {
          'dnd': dndStatus.asBool(),
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
