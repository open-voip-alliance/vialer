import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../data/models/user/permissions/permission.dart';
import '../../../../../../data/models/user/permissions/permission_status.dart';
import '../../../../../../domain/usecases/metrics/track_permission.dart';
import '../../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../controllers/cubit.dart';
import '../../info/info_page.dart';

class PermissionPage extends StatefulWidget {
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

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  final _requestPermission = RequestPermissionUseCase();
  final _trackPermission = TrackPermissionUseCase();

  Future<void> _onContinuePressed() async {
    final status = await _requestPermission(permission: widget.permission);
    context.read<OnboardingCubit>().forward();

    if (status == PermissionStatus.granted) {
      widget.onPermissionGranted?.call();
    }

    _trackPermission(
      type: widget.permission.toShortString(),
      granted: status == PermissionStatus.granted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      icon: widget.icon,
      title: widget.title,
      description: widget.description,
      onPressed: _onContinuePressed,
    );
  }
}
