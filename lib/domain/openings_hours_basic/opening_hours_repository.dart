import '../../app/util/loggable.dart';
import '../user/user.dart';
import 'opening_hours.dart';
import 'opening_hours_service.dart';

class OpeningHoursRepository with Loggable {
  final OpeningHoursService _service;

  OpeningHoursRepository(this._service);

  Future<List<OpeningHoursModule>> getModules({
    required User user,
  }) async {
    final response = await _service.getOpeningHoursModules(
      clientUuid: user.client.uuid,
    );

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get opening hours basic');
      return const [];
    }

    if (response.body['count'] == 0) {
      return const [];
    }

    return _modulesFromJson(response.body['items'] as List<dynamic>);
  }
}

List<OpeningHoursModule> _modulesFromJson(List<dynamic> values) => values
    .map((v) => OpeningHoursModule.fromJson(v as Map<String, dynamic>))
    .toList();
