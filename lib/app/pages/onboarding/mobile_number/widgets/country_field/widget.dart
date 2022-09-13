import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/entities/country.dart';
import '../../../../../resources/localizations.dart';
import '../country_field/cubit.dart';

class CountryFlagField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const CountryFlagField._({
    Key? key,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  static Widget create({
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    return BlocProvider(
      create: (_) => CountryFieldCubit(),
      child: CountryFlagField._(
        controller: controller,
        focusNode: focusNode,
      ),
    );
  }

  @override
  _CountryFlagFieldState createState() => _CountryFlagFieldState();
}

class _CountryFlagFieldState extends State<CountryFlagField> {
  String _mobileNumber = '';

  void _handleMobileNumberRetrieval() {
    if (widget.controller.value.text.length > 4) {
      _mobileNumber = widget.controller.value.text;

      context
          .read<CountryFieldCubit>()
          .pickCountryByMobileNumber(_mobileNumber);

      // Remove listener, so we effectively only listen once when the mobile
      // number from the VG api returns.
      widget.controller.removeListener(_handleMobileNumberRetrieval);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widget.controller.addListener(_handleMobileNumberRetrieval);
  }

  void _onStateChanged(BuildContext context, CountryFieldState state) {
    if (state is CountriesLoaded) {
      if (_mobileNumber == '') {
        widget.controller.text = '+${state.currentCountry.callingCode}';
      } else {
        context
            .read<CountryFieldCubit>()
            .pickCountryByMobileNumber(_mobileNumber);
      }
    }
  }

  void _pickCountry(
    BuildContext context,
    CountryFieldCubit cubit,
    Country country,
  ) {
    _mobileNumber = '';

    cubit.changeCountry(country);

    Navigator.of(context).pop(); // Dismiss the bottom sheet.
  }

  void _onFlagPressed() {
    final cubit = context.read<CountryFieldCubit>();
    final state = cubit.state;
    final countries = state is CountriesLoaded ? state.countries.toList() : [];

    // The country field widget is used as a prefix icon for the mobile
    // number text field. Clicking the flag icon will show a
    // modal bottom sheet. However, the focus is first passed
    // through to the text field itself. The result is that the
    // normal keyboard is shortly shown before showing the
    // bottom sheet.
    // https://github.com/flutter/flutter/issues/36948
    // So take a way the focus first.

    widget.focusNode.unfocus();
    widget.focusNode.canRequestFocus = false;

    _showCountryBottomSheet(countries, cubit);

    // Restore the focus.
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.focusNode.canRequestFocus = true;
    });
  }

  Future _showCountryBottomSheet(
    List countries,
    CountryFieldCubit cubit,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.msg.onboarding.mobileNumber.country),
            ),
            Expanded(
              child: DraggableScrollableSheet(
                initialChildSize: 1.0,
                builder: (context, scrollController) {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index] as Country;

                      return ListTile(
                        minLeadingWidth: 10,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: Padding(
                          padding: const EdgeInsets.only(
                            top: 2,
                            right: 0,
                          ),
                          child: Text(
                            country.flag,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          '${country.name} (+${country.callingCode})',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => _pickCountry(context, cubit, country),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CountryFieldCubit, CountryFieldState>(
      listener: _onStateChanged,
      child: BlocBuilder<CountryFieldCubit, CountryFieldState>(
        builder: (context, state) {
          if (state is CountriesLoaded) {
            return MaterialButton(
              minWidth: 0,
              padding: const EdgeInsets.all(0),
              onPressed: _onFlagPressed,
              child: Text(
                state.currentCountry.flag,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          } else {
            return const FaIcon(
              FontAwesomeIcons.mobile,
              color: Colors.grey,
              size: 16,
            );
          }
        },
      ),
    );
  }
}
