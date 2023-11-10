import 'package:injectable/injectable.dart';

import '../../app/util/loggable.dart';
import '../user/user.dart';
import 'opening_hours.dart';
import 'opening_hours_service.dart';

@injectable
class OpeningHoursRepository with Loggable {
  OpeningHoursRepository(this._service);

  final OpeningHoursService _service;

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

    final body = response.body!;

    if (body['count'] == 0) {
      return const [];
    }

    return _modulesFromJson(body['items'] as List<dynamic>);
  }
}

List<OpeningHoursModule> _modulesFromJson(List<dynamic> values) => values
    .map((dynamic v) => OpeningHoursModule.fromJson(v as Map<String, dynamic>))
    .toList();
