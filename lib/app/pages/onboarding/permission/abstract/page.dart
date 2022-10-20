import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../cubit.dart';
import '../../info/page.dart';
import 'cubit.dart';

class PermissionPage extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget description;
  final Permission permission;
  final VoidCallback? onPermissionGranted;

  /// When set to TRUE, the user will be provided with a clear choice between
  /// providing consent which will display the permission dialog and not
  /// providing consent, which will skip it.
  final bool requestConsent;

  PermissionPage({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.permission,
    this.onPermissionGranted,
    this.requestConsent = false,
  }) : super(key: key);

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
              onConsentDeclined: requestConsent
                  ? context.watch<OnboardingCubit>().forward
                  : null,
            ),
          );
        },
      ),
    );
  }
}
