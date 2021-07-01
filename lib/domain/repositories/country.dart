import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import 'package:dartx/dartx.dart';

import '../entities/country.dart';
import '../repositories/mappers/country.dart';

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
