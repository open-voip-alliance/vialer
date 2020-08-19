import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/localizations.dart';

import '../cubit.dart';
import 'cubit.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Timer(
      Duration(milliseconds: 1500),
      context.bloc<OnboardingCubit>().forward,
    );
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
                text: '${context.msg.onboarding.welcome.title}\n',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: state.user?.firstName ?? '',
                    style: TextStyle(
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
