import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/bloc.dart';
import '../routes.dart';

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
          Navigator.pushReplacementNamed(context, Routes.dialer);
        } else if (state is NotAuthenticated) {
          Navigator.pushReplacementNamed(context, Routes.onboardingLogin);
        }
      },
      child: Container(),
    );
  }
}
