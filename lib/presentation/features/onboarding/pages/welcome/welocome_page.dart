import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/onboarding/step.dart';
import '../../controllers/cubit.dart';
import '../../controllers/welcome/cubit.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final onboarding = context.read<OnboardingCubit>();

    // When returning to the login screen after logging out, the welcome page
    // is still loaded so we do not want to trigger this forward unless
    // the user is actually on this step of onboarding.
    if (onboarding.state.currentStep == OnboardingStep.welcome) {
      Timer(
        const Duration(milliseconds: 1500),
        onboarding.forward,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WelcomeCubit>(
      create: (_) => WelcomeCubit(),
      child: BlocBuilder<WelcomeCubit, WelcomeState>(
        builder: (context, state) {
          return Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '${context.msg.onboarding.welcome.title(
                  context.brand.appName,
                )}\n',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: context.brand.theme.colors.primary,
                ),
                children: [
                  TextSpan(
                    text: state.user?.firstName ?? '',
                    style: TextStyle(
                      fontSize: 50,
                      color: context.brand.theme.colors.primary,
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
