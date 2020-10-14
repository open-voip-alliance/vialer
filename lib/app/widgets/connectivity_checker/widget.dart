import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';

class ConnectivityChecker extends StatelessWidget {
  final Widget child;

  const ConnectivityChecker({this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityCheckerCubit>(
      create: (_) => ConnectivityCheckerCubit(),
      child: child,
    );
  }
}
