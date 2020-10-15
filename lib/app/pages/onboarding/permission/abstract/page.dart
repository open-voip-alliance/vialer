import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit.dart';
import '../../info/page.dart';

import '../../../../../domain/entities/permission.dart';

import 'cubit.dart';

class PermissionPage extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget description;
  final Permission permission;

  PermissionPage({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.description,
    @required this.permission,
  }) : super(key: key);

  void _onStateChanged(BuildContext context, PermissionState state) {
    if (state is PermissionGranted || state is PermissionDenied) {
      context.bloc<OnboardingCubit>().forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PermissionCubit>(
      create: (_) => PermissionCubit(permission),
      child: Builder(
        builder: (context) {
          return BlocListener<PermissionCubit, PermissionState>(
            listener: _onStateChanged,
            child: InfoPage(
              icon: icon,
              title: title,
              description: description,
              onPressed: context.bloc<PermissionCubit>().request,
            ),
          );
        },
      ),
    );
  }
}
