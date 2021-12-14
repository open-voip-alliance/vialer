import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/brand.dart';
import '../../../resources/localizations.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';
import '../cubit.dart';
import '../widgets/error.dart';
import '../widgets/stylized_text_field.dart';
import 'cubit.dart';
import 'widgets/country_field/widget.dart';

class MobileNumberPage extends StatelessWidget {
  final _mobileNumberController = TextEditingController();
  final _mobileNumberFocusNode = FocusNode();

  void _onContinueButtonPressed(BuildContext context) {
    context
        .read<MobileNumberCubit>()
        .changeMobileNumber(_mobileNumberController.text);
  }

  void _onStateChanged(BuildContext context, MobileNumberState state) {
    _mobileNumberController.text =
        state.mobileNumber == null ? '' : state.mobileNumber as String;

    if (state is MobileNumberAccepted) {
      context.read<OnboardingCubit>().forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MobileNumberCubit(),
      child: BlocConsumer<MobileNumberCubit, MobileNumberState>(
        listener: _onStateChanged,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 48,
            ).copyWith(
              bottom: 24,
            ),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 64),
                  Text(
                    context.msg.onboarding.mobileNumber.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.msg.onboarding.mobileNumber.description(
                      Provider.of<Brand>(context).appName,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ErrorAlert(
                    visible: state is MobileNumberNotAccepted,
                    message: context.msg.onboarding.mobileNumber.error,
                    inline: false,
                  ),
                  StylizedTextField(
                    prefixWidget: CountryFlagField.create(
                      controller: _mobileNumberController,
                      focusNode: _mobileNumberFocusNode,
                    ),
                    controller: _mobileNumberController,
                    focusNode: _mobileNumberFocusNode,
                    labelText: context.msg.onboarding.mobileNumber.title,
                    hintText: context.msg.onboarding.mobileNumber.hint,
                    keyboardType: TextInputType.text,
                    hasError: state is MobileNumberNotAccepted,
                    autoCorrect: false,
                  ),
                  const SizedBox(height: 16),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    child: Text(
                      context.msg.onboarding.mobileNumber.info,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        StylizedButton.raised(
                          onPressed: () => _onContinueButtonPressed(context),
                          child: Text(
                            context.msg.onboarding.mobileNumber.button
                                .toUpperCaseIfAndroid(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
