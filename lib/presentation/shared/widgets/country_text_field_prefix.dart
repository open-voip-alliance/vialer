import 'package:flutter/material.dart';
import 'package:vialer/data/models/onboarding/country.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

class CountryTextFieldPrefix extends StatelessWidget {
  const CountryTextFieldPrefix({
    super.key,
    required this.currentCountry,
    required this.onCountrySelected,
    required this.countries,
    required this.focusNode,
    required this.controller,
  });

  final Country? currentCountry;
  final void Function(Country) onCountrySelected;
  final List<Country> countries;
  final FocusNode focusNode;
  final TextEditingController controller;

  void _onFlagPressed(BuildContext context) {
    // The country field widget is used as a prefix icon for the mobile
    // number text field. Clicking the flag icon will show a
    // modal bottom sheet. However, the focus is first passed
    // through to the text field itself. The result is that the
    // normal keyboard is shortly shown before showing the
    // bottom sheet.
    // https://github.com/flutter/flutter/issues/36948
    // So take a way the focus first.
    focusNode.unfocus();
    focusNode.canRequestFocus = false;

    _showCountryBottomSheet(context);

    // Restore the focus.
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.canRequestFocus = true;
    });
  }

  Future<void> _showCountryBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.msg.onboarding.mobileNumber.country),
            ),
            Expanded(
              child: DraggableScrollableSheet(
                initialChildSize: 1,
                builder: (context, scrollController) {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];

                      return ListTile(
                        minLeadingWidth: 10,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        leading: Padding(
                          padding: const EdgeInsets.only(
                            top: 2,
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
                        onTap: () {
                          onCountrySelected(country);
                          Navigator.of(context).pop();
                        },
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
    final currentCountry = this.currentCountry;
    final iconSize = 16.0;

    return MaterialButton(
      minWidth: 0,
      padding: const EdgeInsets.only(left: 10),
      onPressed: () => _onFlagPressed(context),
      child: currentCountry != null
          ? Text(
              currentCountry.flag,
              style: TextStyle(fontSize: iconSize),
            )
          : Icon(
              context.brand.icon,
              color: context.brand.theme.colors.primary,
              size: iconSize,
            ),
    );
  }
}
