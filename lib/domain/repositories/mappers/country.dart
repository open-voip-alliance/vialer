import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../../entities/country.dart';

extension CountryMapper on CountryWithPhoneCode {
  Country toDomainEntity() {
    return Country(
      name: countryName!,
      isoCode: countryCode,
      callingCode: phoneCode,
    );
  }
}
