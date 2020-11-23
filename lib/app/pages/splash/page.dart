import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../routes.dart';
import '../../widgets/splash_screen.dart';
import '../../widgets/transparent_status_bar.dart';
import 'cubit.dart';

class SplashPage extends StatelessWidget {
  void _onStateChanged(BuildContext context, SplashState state) {
    if (state is IsAuthenticated) {
      Navigator.pushReplacementNamed(context, Routes.main);
    }

    if (state is IsNotAuthenticated) {
      // Push without animation, so the two splash screens appear
      // to be a seamless transition.
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          pageBuilder: (context, _, __) {
            return Routes.mapped[Routes.onboarding](context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TransparentStatusBar(
      brightness: Brightness.light,
      child: BlocProvider<SplashCubit>(
        create: (_) => SplashCubit(),
        child: BlocListener<SplashCubit, SplashState>(
          listener: _onStateChanged,
          child: SplashScreen(),
        ),
      ),
    );
  }
}
