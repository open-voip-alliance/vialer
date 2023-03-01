import '../../app/util/loggable.dart';
import '../user/user.dart';
import 'opening_hours.dart';
import 'opening_hours_service.dart';

class OpeningHoursRepository with Loggable {
  final OpeningHoursService _service;

  OpeningHoursRepository(this._service);

  Future<OpeningHours?> getOpeningHours({
    required User user,
  }) async {
    final response = await _service.getOpeningHours(
      clientUuid: user.client.uuid,
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get opening hours basic');
      return null;
    }

    if (response.body['count'] == 0) {
      return null;
    }

    return OpeningHours.fromJson(
      response.body['items'] as Map<String, dynamic>,
    );
  }
}
