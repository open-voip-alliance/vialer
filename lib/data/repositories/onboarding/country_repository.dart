import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:injectable/injectable.dart';

import '../../models/onboarding/country.dart';

@singleton
class CountryRepository {
  CountryRepository() {
    unawaited(init());
  }

  Future<Iterable<Country>> getCountries() async {
    return CountryManager()
        .countries
        .map((i) => i.toDomainEntity())
        .sortedBy((country) => country.name);
  }
}

extension CountryMapper on CountryWithPhoneCode {
  Country toDomainEntity() {
    return Country(
      name: countryName!,
      isoCode: countryCode,
      callingCode: phoneCode,
    );
  }
}
