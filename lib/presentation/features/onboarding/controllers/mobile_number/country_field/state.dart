import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../../data/models/onboarding/country.dart';

part 'state.freezed.dart';

@freezed
sealed class CountryFieldState with _$CountryFieldState {
  const factory CountryFieldState.loading() = LoadingCountries;
  const factory CountryFieldState.loaded(Iterable<Country> countries) =
      CountriesLoaded;
}
