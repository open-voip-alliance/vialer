import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../domain/onboarding/country.dart';

part 'state.freezed.dart';

@freezed
sealed class CountryFieldState with _$CountryFieldState {
  const factory CountryFieldState.loading() = LoadingCountries;
  const factory CountryFieldState.loaded({
    required Iterable<Country> countries,
    required Country currentCountry,
  }) = CountriesLoaded;
}
