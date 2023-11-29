import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/user/user.dart';

import '../user_availability_status.dart';
import 'availability_status_service.dart';

@injectable
class UserAvailabilityStatusRepository with Loggable {
  UserAvailabilityStatusRepository(this._service);

  final UserAvailabilityService _service;

  Future<UserAvailabilityStatus> getAvailabilityStatus(User user) async {
    final response = await _service.getAvailabilityStatus(
      clientUuid: user.client.uuid,
      userUuid: user.uuid,
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get availability status');
      throw Exception('Unable to get dnd status from the api');
    }

    return UserAvailabilityStatusConversion.fromServer(
      response.body!['status'] as String,
    );
  }

  Future<void> changeStatus(User user, UserAvailabilityStatus status) async {
    final response = await _service.changeAvailabilityStatus(
      {
        'status': status.asServerValue(),
      },
      clientUuid: user.client.uuid,
      userUuid: user.uuid,
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Change availability status');
    }
  }
}

extension UserAvailabilityStatusConversion on UserAvailabilityStatus {
  /// New user statuses will be added in the future, we want to always fallback
  /// to a given default so we can handle these new statuses as best we can.
  static const _default = UserAvailabilityStatus.online;

  static const _mapping = {
    UserAvailabilityStatus.online: 'available',
    UserAvailabilityStatus.doNotDisturb: 'do_not_disturb',
    UserAvailabilityStatus.offline: 'offline',
  };

  String asServerValue() => _mapping.getOrElse(this, () => _mapping[_default]!);

  static UserAvailabilityStatus fromServer(String value) =>
      _mapping.entries.firstOrNullWhere((entry) => entry.value == value)?.key ??
      _default;
}
