import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

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

    emit(
      CountriesLoaded(
        countries: [...mainCountries, ...countries],
        currentCountry: mainCountries.first,
      ),
    );
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
