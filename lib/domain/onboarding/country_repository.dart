import 'package:dartx/dartx.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import 'country.dart';

class CountryRepository {
  CountryRepository() {
    FlutterLibphonenumber().init();
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
