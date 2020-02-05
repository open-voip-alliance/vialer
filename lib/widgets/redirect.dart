import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/bloc.dart';
import '../routes.dart';
import 'splash_screen.dart';
import 'transparent_status_bar.dart';

class Redirect extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    BlocProvider.of<AuthBloc>(context).add(Check());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, Routes.main);
        } else if (state is NotAuthenticated) {
          // Push without animation, so the two splash screens appear
          // to be a seamless transition.
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  Routes.mapped[Routes.onboarding](null),
            ),
          );
        }
      },
      child: TransparentStatusBar(
        brightness: Brightness.light,
        child: SplashScreen(),
      ),
    );
  }
}
