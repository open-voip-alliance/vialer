import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../widgets/connectivity_checker/cubit.dart';
import '../util/stylized_snack_bar.dart';

/// Requires a [Scaffold] ancestor.
class ConnectivityAlert extends StatefulWidget {
  final Widget child;

  const ConnectivityAlert({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityAlertState createState() => _ConnectivityAlertState();
}

class _ConnectivityAlertState extends State<ConnectivityAlert> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showOrHideSnackBar(
        context,
        context.read<ConnectivityCheckerCubit>().state,
      );
    });
  }

  void _showOrHideSnackBar(BuildContext context, ConnectivityState state) {
    if (state is Disconnected) {
      showSnackBar(
        context,
        // Hacky way off showing the snack bar 'forever'
        duration: const Duration(days: 365),
        icon: const Icon(VialerSans.exclamationMark),
        label: Text(context.msg.connectivity.noConnection.message),
      );
    }

    if (state is Connected) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCheckerCubit, ConnectivityState>(
      // Make sure we only display a snackbar on the first disconnected state
      // that we receive.
      listenWhen: (previous, current) =>
          (previous is! Disconnected && current is Disconnected) ||
          current is Connected,
      listener: _showOrHideSnackBar,
      child: widget.child,
    );
  }
}
