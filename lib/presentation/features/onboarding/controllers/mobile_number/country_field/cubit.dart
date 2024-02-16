import 'dart:async';

import 'package:collection/collection.dart';
import 'package:country_codes/country_codes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

import '../../../../../../../data/models/onboarding/country.dart';
import '../../../../../../../domain/usecases/onboarding/get_countries.dart';
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
        currentCountry: await totalCountries.getPreferredCurrentCountry(),
      ),
    );
  }

  /// Retrieves the country from the given list of countries based on the provided criteria.
  /// If no country satisfies the criteria, it falls back to retrieving the preferred country using [_getPreferredCurrentCountry] method.
  ///
  /// Parameters:
  /// - countries: The list of countries to search from.
  /// - criteria: The criteria function used to determine if a country is preferred.
  ///
  /// Returns:
  /// - The country that satisfies the criteria, or the fallback preferred country.
  Future<Country> _getCountryFirstWhere({
    required Iterable<Country> countries,
    required bool Function(Country) criteria,
  }) async =>
      countries.firstWhereOrNull(criteria) ??
      await countries.getPreferredCurrentCountry();

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
      final currentCountry = parsedNumber != null
          ? await _getCountryFirstWhere(
              countries: countries,
              criteria: (Country country) =>
                  country.callingCode == parsedNumber!['country_code'],
            )
          : await countries.getPreferredCurrentCountry();

      emit(
        CountriesLoaded(
          countries: countries,
          currentCountry: currentCountry,
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

extension PreferredCountry on Iterable<Country> {
  /// Retrieves the preferred current country based on the device's locale.
  ///
  /// This method initializes the country codes and then retrieves the ISO code of the device's locale.
  /// It then searches for the first country in the list that matches the ISO code.
  /// If no match is found, it returns the first country in the list.
  ///
  /// Returns the preferred current country.
  Future<Country> getPreferredCurrentCountry() async {
    await CountryCodes.init();
    final countryIsoCode = CountryCodes.detailsForLocale().alpha2Code;

    return this.firstWhere(
      (Country country) => country.isoCode == countryIsoCode,
      orElse: () => this.first,
    );
  }
}
