import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/shared/widgets/country_text_field_prefix.dart';

import '../../../../../../../data/models/onboarding/country.dart';
import '../../../controllers/mobile_number/country_field/cubit.dart';

class CountryFlagField extends StatefulWidget {
  const CountryFlagField({
    required this.controller,
    required this.focusNode,
    this.initialValue,
  });

  final TextEditingController controller;
  final String? initialValue;
  final FocusNode focusNode;

  @override
  State<CountryFlagField> createState() => CountryFlagFieldState();
}

class CountryFlagFieldState<T extends CountryFlagField> extends State<T> {
  Country? selectedCountry;

  void _initializeStartingCountry() async {
    final country = await context
        .read<CountriesCubit>()
        .chooseCountryBasedOnUser(widget.initialValue ?? null);

    _changeCountry(
      country,
      updateTextField:
          widget.initialValue == null && widget.controller.text.length <= 4,
    );
  }

  @override
  void initState() {
    _initializeStartingCountry();
    super.initState();
  }

  /// Change the country, you may not want to update the text field if there
  /// is another number in there, in that case set [updateTextField] to false.
  void _changeCountry(
    Country? country, {
    bool updateTextField = true,
  }) {
    if (country == null) return;

    setState(() {
      selectedCountry = country;
      if (!updateTextField) return;
      widget.controller.text = '+${country.callingCode}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountriesCubit, CountryFieldState>(
      builder: (context, state) {
        return CountryTextFieldPrefix(
          currentCountry: selectedCountry,
          onCountrySelected: _changeCountry,
          countries: state.countries,
          focusNode: widget.focusNode,
          controller: widget.controller,
        );
      },
    );
  }
}

extension on CountryFieldState {
  List<Country> get countries => this is CountriesLoaded
      ? (this as CountriesLoaded).countries.toList()
      : const [];
}
