import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/brand.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../widgets/stylized_button.dart';
import '../cubit.dart';
import '../widgets/error.dart';
import '../widgets/stylized_text_field.dart';
import 'cubit.dart';

class MobileNumberPage extends StatelessWidget {
  final _mobileNumberController = TextEditingController();

  void _onContinueButtonPressed(BuildContext context) {
    context
        .read<MobileNumberCubit>()
        .changeMobileNumber(_mobileNumberController.text);
  }

  void _onStateChanged(BuildContext context, MobileNumberState state) {
    _mobileNumberController.text =
        state.mobileNumber == null ? '' : state.mobileNumber as String;
    if (state is MobileNumberChanged) {
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
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(context.msg.onboarding.mobileNumber.title),
                  ),
                  const SizedBox(height: 32),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    child: Text(
                      context.msg.onboarding.mobileNumber.description(
                        Provider.of<Brand>(context).appName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ErrorAlert(
                    visible: state is MobileNumberNotChanged,
                    message: context.msg.onboarding.mobileNumber.error,
                    inline: false,
                  ),
                  StylizedTextField(
                    prefixIcon: VialerSans.mobilePhone,
                    controller: _mobileNumberController,
                    labelText: context.msg.onboarding.mobileNumber.title,
                    keyboardType: TextInputType.phone,
                    hasError: state is MobileNumberNotChanged,
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
                            context.msg.onboarding.mobileNumber.button,
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
