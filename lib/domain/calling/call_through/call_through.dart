import 'dart:io';

import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../app/util/loggable.dart';
import '../../../app/util/pigeon.dart' as native;
import '../../user/settings/call_setting.dart';
import '../../user/user.dart';
import '../../voipgrid/voipgrid_service.dart';
import 'call_through_exception.dart';

class CallThroughRepository with Loggable {
  final VoipgridService _service;

  CallThroughRepository(this._service);

  Future<void> call(
    String destination,
    String? regionNumber, {
    required User user,
  }) async {
    if (regionNumber == null) {
      throw CallThroughException();
    }

    if (Platform.isAndroid) {
      native.CallThrough().startCall(regionNumber);
    } else {
      await launchUrlString('tel:$regionNumber');
    }
  }

  Future<String> retrieveRegionNumber(
    String destination, {
    required User user,
  }) async {
    final mobileNumber = user.settings.get(CallSetting.mobileNumber);

    // If there's no mobile number set, throw an exception.
    if (mobileNumber.isEmpty) {
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
    }

    final error = response.error as String;

    // A mapping of all the possible error codes we might expect in the response
    // and the exceptions that should be thrown if they are found.
    final possibleErrors = {
      'invalid_destination': InvalidDestinationException(),
      'no_mobile_number': NoMobileNumberException(),
      'unsupported_region': UnsupportedRegionException(),
    };

    for (final possibleError in possibleErrors.entries) {
      if (error.contains(possibleError.key)) {
        throw possibleError.value;
      }
    }

    throw CallThroughException();
  }

  Future<String> _normalizePhoneNumber({
    required String number,
    required User user,
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

  /// We are attempting to guess what country code the user intends to dial
  /// with so we will attempt with various data until we find a usable ISO code.
  String _findIsoCode({required User user}) {
    final numbers = [
      user.settings.get(CallSetting.outgoingNumber).valueOrEmpty,
      user.settings.get(CallSetting.mobileNumber),
    ];

    for (final number in numbers) {
      final isoCode = _findIsoCodeForPhoneNumber(number);

      if (isoCode != null) return isoCode;
    }

    logger.warning(
      'Unable to find relevant ISO code. This means their outgoing CLI '
      'or mobile number is from an unsupported region. User should use '
      'a full number including a country code to make call-through calls.',
    );

    throw IsoCodeNotFoundException();
  }

  String? _findIsoCodeForPhoneNumber(String number) {
    final supportedIsoCodes = {
      'NL': '31',
      'DE': '49',
      'BE': '32',
      'ZA': '27',
    };

    for (final entry in supportedIsoCodes.entries) {
      if (number.startsWith('+${entry.value}')) return entry.key;
    }

    return null;
  }
}

extension CallThrough on String {
  bool get isInternalNumber =>
      length <= 9 || (length == 10 && !startsWith('0'));
}
