import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../../../util/brand.dart';
import '../widgets/caller.dart';
import '../widgets/caller/state.dart';
import '../widgets/connectivity_alert.dart';
import 'cubit.dart';
import 'widgets/dialer/widget.dart';

class DialerPage extends StatefulWidget {
  final bool isInBottomNavBar;

  const DialerPage({Key? key, required this.isInBottomNavBar})
      : super(key: key);

  @override
  _DialerPageState createState() => _DialerPageState();
}

// ignore: prefer_mixin
class _DialerPageState extends State<DialerPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final callerState = context.read<CallerCubit>().state;

      // We pop the dialer on Android if we're initiating a call-through call.
      if (Platform.isAndroid &&
          callerState is InitiatingCall &&
          !callerState.isVoip) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == Routes.main,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      context.read<CallerCubit>().checkCallPermissionIfNotVoip();
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider<DialerCubit>(
        create: (context) => DialerCubit(context.read<CallerCubit>()),
        child: BlocBuilder<CallerCubit, CallerState>(builder: (context, state) {
          final body = Dialer(
            buttonColor: context.brand.theme.green1,
            buttonIcon: VialerSans.phone,
            onCall: (number) {
              context.read<DialerCubit>().call(number);
            },
          );

          return Scaffold(
            body: !widget.isInBottomNavBar
                ? ConnectivityAlert(
                    child: body,
                  )
                : body,
          );
        }),
      );

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance!.removeObserver(this);
  }
}
