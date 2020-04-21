import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/call_through_exception.dart';
import '../../domain/repositories/call.dart';

import 'services/voipgrid.dart';

class DataCallRepository extends CallRepository {
  final VoipgridService _service;

  DataCallRepository(this._service);

  @override
  Future<void> call(String destination) async {
    // Get real number to call
    final response = await _service.callthrough(destination: destination);
    if (response.isSuccessful) {
      destination = response.body['phonenumber'];

      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.CALL',
          data: 'tel:$destination',
        );

        await intent.launch();
      } else {
        await launch('tel:$destination');
      }
    } else {
      final error = json.decode(response.error) as Map<String, dynamic>;
      final destinationError = error['destination'] as List<dynamic>;
      if (destinationError != null && destinationError.isNotEmpty) {
        final first = destinationError.first as Map<String, dynamic>;
        if (first['code'] == 'invalid_destination') {
          throw InvalidDestinationException();
        }
      }

      throw CallThroughException();
    }
  }
}
