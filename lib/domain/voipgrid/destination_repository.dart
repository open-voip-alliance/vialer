import 'dart:async';

import 'availability.dart';
import 'voipgrid_service.dart';

class DestinationRepository {
  final VoipgridService _service;

  DestinationRepository(this._service);

  Future<Availability?> getLatestAvailability() async {
    final response = await _service.getAvailability();

    if (!response.isSuccessful) return null;

    final objects = response.body['objects'] as List<dynamic>? ?? [];

    if (objects.isEmpty) return null;

    return objects
        .map((obj) => Availability.fromJson(obj as Map<String, dynamic>))
        .toList()
        .first;
  }

  Future<bool> setAvailability({
    required int selectedDestinationId,
    int? phoneAccountId,
    int? fixedDestinationId,
  }) async {
    assert(!(phoneAccountId != null && fixedDestinationId != null));

    return await _service.setAvailability(
      selectedDestinationId.toString(),
      {
        'phoneaccount': phoneAccountId?.toString(),
        'fixeddestination': fixedDestinationId?.toString(),
      },
    ).then((r) => r.isSuccessful);
  }
}
