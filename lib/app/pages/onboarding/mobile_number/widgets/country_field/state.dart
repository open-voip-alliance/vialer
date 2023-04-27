import 'package:equatable/equatable.dart';

import '../../../../../../domain/onboarding/country.dart';

abstract class CountryFieldState extends Equatable {
  const CountryFieldState();

  @override
  List<Object?> get props => [];
}

class LoadingCountries extends CountryFieldState {
  const LoadingCountries();
}

class CountriesLoaded extends CountryFieldState {
  const CountriesLoaded({
    required this.countries,
    required this.currentCountry,
  });

  final Iterable<Country> countries;
  final Country currentCountry;

  @override
  List<Object?> get props => [countries, currentCountry];
}
