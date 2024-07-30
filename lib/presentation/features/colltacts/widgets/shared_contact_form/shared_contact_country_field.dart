import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../onboarding/controllers/mobile_number/country_field/cubit.dart';
import '../../../onboarding/widgets/mobile_number/country_field/widget.dart';

class SharedContactCountryField extends CountryFlagField {
  const SharedContactCountryField._({
    required super.controller,
    required super.focusNode,
    this.initialValue,
    this.mobileNumber,
  });

  final String? initialValue;
  final String? mobileNumber;

  static Widget create({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? initialValue,
    String? mobileNumber,
  }) {
    return BlocProvider(
      create: (_) => CountryFieldCubit(),
      child: SharedContactCountryField._(
        controller: controller,
        focusNode: focusNode,
        initialValue: initialValue,
        mobileNumber: mobileNumber,
      ),
    );
  }

  @override
  SharedContactCountryFieldState createState() =>
      SharedContactCountryFieldState();
}

class SharedContactCountryFieldState<T extends SharedContactCountryField>
    extends CountryFlagFieldState<T> {
  @override
  void initState() {
    _loadCountryBasedOnProvidedNumber();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    widget.focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCountryBasedOnProvidedNumber() async {
    final initialValue = widget.initialValue;
    final mobileNumber = widget.mobileNumber;

    final queryNumber = initialValue ?? mobileNumber;

    if (queryNumber == null) return;

    final cubit = context.read<CountryFieldCubit>();

    // We don't want to run this until the countries have been loaded in
    // otherwise it won't work.
    if (cubit.state is CountriesLoaded) {
      cubit.pickCountryByMobileNumber(queryNumber);
    } else {
      cubit.stream
          .where((state) => state is CountriesLoaded)
          .listen((state) => cubit.pickCountryByMobileNumber(queryNumber));
    }
  }

  @override
  void onStateChanged(BuildContext context, CountryFieldState state) {
    if (state is! CountriesLoaded) return;

    if (widget.initialValue == null) {
      widget.controller.text = '+${state.currentCountry.callingCode}';
    }
  }

  @override
  void handleMobileNumberRetrieval() {}
}
