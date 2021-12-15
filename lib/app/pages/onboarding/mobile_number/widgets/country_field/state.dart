import 'package:equatable/equatable.dart';

import '../../../../../../domain/entities/country.dart';

abstract class CountryFieldState extends Equatable {
  @override
  List<Object?> get props => [];

  const CountryFieldState();
}

class LoadingCountries extends CountryFieldState {
  const LoadingCountries();
}

class CountriesLoaded extends CountryFieldState {
  final Iterable<Country> countries;
  final Country currentCountry;

  const CountriesLoaded({
    required this.countries,
    required this.currentCountry,
  });

  @override
  List<Object?> get props => [countries, currentCountry];
}
