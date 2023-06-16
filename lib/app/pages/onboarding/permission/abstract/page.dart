import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../cubit.dart';
import '../../info/page.dart';
import 'cubit.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.permission,
    this.onPermissionGranted,
    super.key,
  });

  final Widget icon;
  final String title;
  final Widget description;
  final Permission permission;
  final VoidCallback? onPermissionGranted;

  void _onStateChanged(BuildContext context, PermissionState state) {
    if (state is PermissionGranted || state is PermissionDenied) {
      context.read<OnboardingCubit>().forward();

      if (state is PermissionGranted) {
        onPermissionGranted?.call();
      }
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
              onPressed: context.watch<PermissionCubit>().request,
            ),
          );
        },
      ),
    );
  }
}
