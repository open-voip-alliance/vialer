import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api/api.dart';
import 'auth/bloc.dart';
import 'onboarding/login/bloc.dart';
import 'onboarding/login/page.dart';
import 'widgets/redirect.dart';

abstract class Routes {
  static const root = '/';
  static const onboardingLogin = '/onboarding/login';

  static const dialer = '/dialer';

  static final mapped = {
    Routes.root: (_) => Redirect(),
    Routes.onboardingLogin: (_) => BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            api: context.api,
            authBloc: context.bloc<AuthBloc>(),
          ),
          child: LoginPage(),
        ),
    Routes.dialer: (_) => Container(),
  };
}
