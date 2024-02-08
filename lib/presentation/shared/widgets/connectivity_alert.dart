import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../util/stylized_snack_bar.dart';
import '../controllers/connectivity_checker/cubit.dart';

/// Requires a [Scaffold] ancestor.
class ConnectivityAlert extends StatefulWidget {
  const ConnectivityAlert({required this.child, super.key});

  final Widget child;

  @override
  State<ConnectivityAlert> createState() => _ConnectivityAlertState();
}

class _ConnectivityAlertState extends State<ConnectivityAlert> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOrHideSnackBar(
        context,
        context.read<ConnectivityCheckerCubit>().state,
      );
    });
  }

  void _showOrHideSnackBar(BuildContext context, ConnectivityState state) {
    if (state is Disconnected) {
      final message = context.msg.connectivity.noConnection.message;

      SemanticsService.announce(
        message,
        Directionality.of(context),
        assertiveness: Assertiveness.assertive,
      );

      showSnackBar(
        context,
        // Hacky way of showing the snack bar 'forever'
        duration: const Duration(days: 365),
        icon: const FaIcon(FontAwesomeIcons.exclamation),
        label: Text(message),
      );
    }

    if (state is Connected) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCheckerCubit, ConnectivityState>(
      // Make sure we only display a snack bar on the first disconnected state
      // that we receive.
      listenWhen: (previous, current) =>
          (previous is! Disconnected && current is Disconnected) ||
          current is Connected,
      listener: _showOrHideSnackBar,
      child: widget.child,
    );
  }
}
