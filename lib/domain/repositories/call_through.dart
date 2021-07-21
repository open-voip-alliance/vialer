import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';

import 'package:url_launcher/url_launcher.dart';

import '../entities/exceptions/call_through.dart';
import '../entities/system_user.dart';
import 'services/voipgrid.dart';

class CallThroughRepository {
  final VoipgridService _service;

  CallThroughRepository(this._service);

  Future<void> call(
    String destination, {
    required SystemUser user,
  }) async {
    final mobileNumber = user.mobileNumber;
    // If there's no mobile number set, throw an exception.
    if (mobileNumber == null || mobileNumber.isEmpty) {
      throw NoMobileNumberException();
    }

    try {
      // The call-through API expects a normalized number.
      // TODO: Don't normalize locally when the API has improved
      // normalization. Remove normalization here when that has happened.
      final possibleDestination = await PhoneNumberUtil.normalizePhoneNumber(
        phoneNumber: destination,
        isoCode: user.outgoingCli!.startsWith('+31') ? 'NL' : 'DE',
      );

      if (possibleDestination == null) {
        throw NormalizationException();
      }

      destination = possibleDestination;
    } on PlatformException catch (e) {
      const message = 'The string supplied is too long to be a phone number.';
      if (e.message == message) {
        throw NumberTooLongException();
      }
      throw NormalizationException();
    }

    // Get real number to call.
    final response = await _service.callthrough(destination: destination);
    if (response.isSuccessful) {
      destination = response.body['phonenumber'] as String;

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
      final error =
          json.decode(response.error as String) as Map<String, dynamic>;
      final destinationError = error['destination'] as List<dynamic>?;
      if (destinationError != null && destinationError.isNotEmpty) {
        final first = destinationError.first as Map<String, dynamic>;
        if (first['code'] == 'invalid_destination') {
          throw InvalidDestinationException();
        }
      }

      final noMobileNumberError = error['user'] as List<dynamic>?;
      if (noMobileNumberError != null && noMobileNumberError.isNotEmpty) {
        final first = noMobileNumberError.first as Map<String, dynamic>;
        if (first['code'] == 'no_mobile_number') {
          throw NoMobileNumberException();
        }
      }

      throw CallThroughException();
    }
  }
}
