import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entities/exceptions/call_through.dart';
import 'auth.dart';
import 'services/voipgrid.dart';
import 'storage.dart';

class CallThroughRepository {
  final VoipgridService _service;
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;

  CallThroughRepository(
    this._service,
    this._storageRepository,
    this._authRepository,
  );

  Future<void> call(String destination) async {
    final mobileNumber = _authRepository.currentUser?.mobileNumber;
    // If there's no mobile number set, throw an exception.
    if (mobileNumber == null || mobileNumber?.isEmpty == true) {
      throw NoMobileNumberException();
    }

    _storageRepository.lastDialedNumber = destination;

    try {
      // The call-through API expects a normalized number.
      // TODO: Don't normalize locally when the API has improved
      // normalization. Remove normalization here when that has happened.
      destination = await PhoneNumberUtil.normalizePhoneNumber(
        phoneNumber: destination,
        isoCode: _authRepository.currentUser.outgoingCli.startsWith('+31')
            ? 'NL'
            : 'DE',
      );
    } on PlatformException {
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
