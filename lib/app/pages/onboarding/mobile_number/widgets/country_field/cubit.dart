import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import '../../../../../../domain/entities/country.dart';
import '../../../../../../domain/usecases/get_countries.dart';

import 'state.dart';
export 'state.dart';

class CountryFieldCubit extends Cubit<CountryFieldState> {
  final _getCountries = GetCountriesUseCase();

  CountryFieldCubit() : super(const LoadingCountries()) {
    _loadCountries();
  }

  void _loadCountries() async {
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
      Map? parsedNumber;
      try {
        parsedNumber = await FlutterLibphonenumber().parse(mobileNumber);
      } on PlatformException {}

      final countries = state.countries;
      final country = parsedNumber != null
          ? countries.firstWhereOrNull(
              (country) => country.callingCode == parsedNumber!['country_code'],
            )
          : null;

      emit(
        CountriesLoaded(
          countries: countries,
          currentCountry: country == null ? countries.first : country,
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
