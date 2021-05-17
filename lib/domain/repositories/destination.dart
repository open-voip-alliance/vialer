import 'dart:async';

import '../entities/availability.dart';
import 'services/voipgrid.dart';

class DestinationRepository {
  final VoipgridService _service;

  DestinationRepository(this._service);

  Future<Availability?> getLatestAvailability() async {
    final response = await _service.getAvailability();
    final objects = response.body['objects'] as List<dynamic>? ?? [];

    if (objects.isEmpty) return null;

    return objects
        .map((obj) => Availability.fromJson(obj as Map<String, dynamic>))
        .toList()
        .first;
  }

  Future<void> setAvailability({
    required int selectedDestinationId,
    int? phoneAccountId,
    int? fixedDestinationId,
  }) async {
    assert(!(phoneAccountId != null && fixedDestinationId != null));

    await _service.setAvailability(
      selectedDestinationId.toString(),
      {
        'phoneaccount': phoneAccountId?.toString(),
        'fixeddestination': fixedDestinationId?.toString(),
      },
    );
  }
}
