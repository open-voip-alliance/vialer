import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/onboarding/step.dart';

import '../../../resources/localizations.dart';
import '../../../util/brand.dart';
import '../cubit.dart';
import 'cubit.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
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
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: state.user?.firstName ?? '',
                    style: const TextStyle(
                      fontSize: 50,
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
