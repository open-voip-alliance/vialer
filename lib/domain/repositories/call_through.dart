import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/util/loggable.dart';
import '../entities/exceptions/call_through.dart';
import '../entities/system_user.dart';
import 'services/voipgrid.dart';

class CallThroughRepository with Loggable {
  final VoipgridService _service;

  CallThroughRepository(this._service);

  Future<void> call(
    String destination,
    String? regionNumber, {
    required SystemUser user,
  }) async {
    if (regionNumber == null) {
      throw CallThroughException();
    }

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: 'tel:$regionNumber',
      );

      await intent.launch();
    } else {
      await launch('tel:$regionNumber');
    }
  }

  Future<String> retrieveRegionNumber(
    String destination, {
    required SystemUser user,
  }) async {
    final mobileNumber = user.mobileNumber;

    // If there's no mobile number set, throw an exception.
    if (mobileNumber == null || mobileNumber.isEmpty) {
      throw NoMobileNumberException();
    }

    try {
      destination = await _normalizePhoneNumber(
        number: destination,
        user: user,
      );
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
      return destination = response.body['phonenumber'] as String;
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

  Future<String> _normalizePhoneNumber({
    required String number,
    required SystemUser user,
  }) async {
    if (number.isInternalNumber) return number;

    // [PhoneNumberUtil] doesn't like using 00 instead of + for international
    // numbers so we will just swap it out.
    if (number.startsWith('00')) {
      number = number.replaceFirst('00', '+');
    }

    // If there is already a country code, we don't want to change it.
    final isoCode = number.startsWith('+') ? '' : _findIsoCode(user: user);

    logger.info('Attempting call-through using ISO code: $isoCode');

    final normalizedNumber = await PhoneNumberUtil.normalizePhoneNumber(
      phoneNumber: number,
      isoCode: isoCode,
    );

    if (normalizedNumber == null) {
      throw NormalizationException();
    }

    return normalizedNumber;
  }

  String _findIsoCode({required SystemUser user}) {
    final outgoingCli = user.outgoingCli!;

    final supportedIsoCodes = {
      'NL': '31',
      'DE': '49',
      'BE': '32',
      'ZA': '27',
    };

    for (final entry in supportedIsoCodes.entries) {
      if (outgoingCli.startsWith('+${entry.value}')) return entry.key;
    }

    throw NormalizationException();
  }
}

extension CallThrough on String {
  bool get isInternalNumber =>
      length <= 9 || (length == 10 && !startsWith('0'));
}
