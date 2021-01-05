import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../entities/availability.dart';
import 'services/voipgrid.dart';

class DestinationRepository {
  final VoipgridService _service;

  DestinationRepository(this._service);

  Future<Availability> getLatestAvailability() async {
    final response = await _service.getAvailability();
    final objects = response.body['objects'] as List<dynamic> ?? [];

    Availability availability;
    if (objects.isNotEmpty) {
      availability = objects
          .map((obj) => Availability.fromJson(obj as Map<String, dynamic>))
          .toList()
          .first;
    }

    return availability;
  }

  Future<void> setAvailability({
    @required int selectedDestinationId,
    int phoneAccountId,
    int fixedDestinationId,
  }) async {
    assert(selectedDestinationId != null);
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
