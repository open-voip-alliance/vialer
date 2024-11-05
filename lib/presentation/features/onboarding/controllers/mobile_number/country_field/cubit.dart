import 'dart:async';

import 'package:collection/collection.dart';
import 'package:country_codes/country_codes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:vialer/data/models/user/settings/call_setting.dart';
import 'package:vialer/data/models/user/user.dart';
import 'package:vialer/domain/usecases/user/get_logged_in_user.dart';
import 'package:vialer/presentation/util/phone_number.dart';

import '../../../../../../../data/models/onboarding/country.dart';
import '../../../../../../../domain/usecases/onboarding/get_countries.dart';
import 'state.dart';

export 'state.dart';

class CountriesCubit extends Cubit<CountryFieldState> {
  CountriesCubit() : super(const LoadingCountries()) {
    unawaited(_loadCountries());
  }

  final _getCountries = GetCountriesUseCase();
  final _getUser = GetLoggedInUserUseCase();

  Future<void> _loadCountries() async {
    final countries = await _getCountries();

    final mainCountries = countries.where(
      (country) => ['NL', 'DE', 'BE', 'ZA'].contains(country.isoCode),
    );

    final totalCountries = [...mainCountries, ...countries];

    emit(CountriesLoaded(totalCountries));
  }

  Future<Country?> get preferredCountry async => state is CountriesLoaded
      ? (state as CountriesLoaded).countries.getPreferredCurrentCountry()
      : null;

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

  /// Automatically chooses the appropriate country based on the logged in user
  /// preferring for the country with the same calling code as the user's mobile
  /// number but falling back to the user's locale.
  ///
  /// Provide [queryNumber] to override this and choose the country based on
  /// this number instead. Only falling back if this number is invalid.
  Future<Country?> chooseCountryBasedOnUser([String? queryNumber]) async {
    if (queryNumber != null &&
        !queryNumber.startsWith('+') &&
        queryNumber.isInternalNumber) {
      return null;
    }

    final mobileNumber = _getUser().settings.get(CallSetting.mobileNumber);

    // We're going to wait for the countries to be loaded before we continue
    // otherwise we won't get a result.
    final state = (this.state is CountriesLoaded
            ? this.state
            : await stream.firstWhere((state) => state is CountriesLoaded))
        as CountriesLoaded;

    var countryCode = await _getCountryCode(queryNumber ?? mobileNumber);

    // Fallback to try the mobile number if query number doesn't find a country
    if (countryCode == null && queryNumber != null) {
      countryCode = await _getCountryCode(mobileNumber);
    }

    return countryCode != null
        ? await _getCountryFirstWhere(
            countries: state.countries,
            criteria: (Country country) => country.callingCode == countryCode,
          )
        : await preferredCountry;
  }

  String? _getCountryCode(String number) {
    if (!number.startsWith('+') && number.length <= 10) return null;

    return formatNumberSync(number)
        .split(' ')
        .firstOrNull
        ?.replaceFirst('+', '');
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

    return firstWhere(
      (Country country) => country.isoCode == countryIsoCode,
      orElse: () => first,
    );
  }
}
