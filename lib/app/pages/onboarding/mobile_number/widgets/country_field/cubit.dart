import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:country_codes/country_codes.dart';

import '../../../../../../domain/onboarding/country.dart';
import '../../../../../../domain/onboarding/get_countries.dart';
import 'state.dart';

export 'state.dart';

class CountryFieldCubit extends Cubit<CountryFieldState> {
  CountryFieldCubit() : super(const LoadingCountries()) {
    unawaited(_loadCountries());
  }

  final _getCountries = GetCountriesUseCase();

  Future<void> _loadCountries() async {
    final countries = await _getCountries();

    final mainCountries = countries.where(
      (country) => ['NL', 'DE', 'BE', 'ZA'].contains(country.isoCode),
    );

    final totalCountries = [...mainCountries, ...countries];

    emit(
      CountriesLoaded(
        countries: totalCountries,
        currentCountry:
            await _getPreferredCurrentCountry(countries: totalCountries),
      ),
    );
  }

  /// Retrieves the preferred country from a list of countries.
  ///
  /// The preferred country is determined by the current locale of the device.
  /// It uses the `CountryCodes` library to initialize the country codes and
  /// retrieve the ISO code of the current locale. Then, it searches for the
  /// country in the provided list of countries that matches the ISO code.
  /// If no match is found, it returns the first country in the list.
  ///
  /// Parameters:
  /// - `countries`: The list of countries to search from.
  ///
  /// Returns:
  /// The preferred country.
  Future<Country> _getPreferredCurrentCountry(
      {required Iterable<Country> countries}) async {
    await CountryCodes.init();
    final String? countryIsoCode = CountryCodes.detailsForLocale().alpha2Code;
    Country preferredCountry = countries.firstWhere(
      (Country country) => country.isoCode == countryIsoCode,
      orElse: () => countries.first,
    );

    return preferredCountry;
  }

  Future<void> pickCountryByMobileNumber(String mobileNumber) async {
    final state = this.state;
    if (state is CountriesLoaded) {
      Map<String, dynamic>? parsedNumber;
      try {
        parsedNumber = await parse(mobileNumber);
      } on PlatformException {
        // Parsing failed and parsedNumber stays null.
      }

      final countries = state.countries;
      final country = parsedNumber != null
          ? countries.firstWhereOrNull(
              (country) => country.callingCode == parsedNumber!['country_code'],
            )
          : null;

      emit(
        CountriesLoaded(
          countries: countries,
          currentCountry: country ?? countries.first,
        ),
      );
    }
  }

  void changeCountry(Country country) {
    final state = this.state;
    if (state is CountriesLoaded) {
      emit(
        CountriesLoaded(
          countries: state.countries,
          currentCountry: country,
        ),
      );
    }
  }
}
