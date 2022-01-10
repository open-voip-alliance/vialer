import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/caller.dart';
import '../widgets/conditional_placeholder.dart';
import '../widgets/connectivity_alert.dart';
import '../widgets/t9_dial_pad.dart';
import 'cubit.dart';

class DialerPage extends StatefulWidget {
  final bool isInBottomNavBar;

  const DialerPage({
    Key? key,
    required this.isInBottomNavBar,
  }) : super(key: key);

  @override
  _DialerPageState createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  final _dialPadController = TextEditingController();

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

  void _onDialerStateChanged(BuildContext context, DialerState state) {
    if (state.lastCalledDestination != null &&
        _dialPadController.text.isEmpty) {
      _dialPadController.text = state.lastCalledDestination!;
    }
  }

  void _onCallButtonPressed(BuildContext context, String number) =>
      context.read<DialerCubit>().call(number);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DialerCubit>(
      create: (context) => DialerCubit(context.read<CallerCubit>()),
      child: BlocListener<DialerCubit, DialerState>(
        listener: _onDialerStateChanged,
        child: BlocBuilder<CallerCubit, CallerState>(
          builder: (context, state) {
            final appName = context.brand.appName;
            final callerCubit = context.watch<CallerCubit>();
            final dialerCubit = context.watch<DialerCubit>();

            final body = SafeArea(
              child: ConditionalPlaceholder(
                showPlaceholder: state is NoPermission,
                placeholder: Warning(
                  title: Text(
                    context.msg.main.dialer.noPermission.title,
                  ),
                  description: state is NoPermission && !state.dontAskAgain
                      ? Text(
                          context.msg.main.dialer.noPermission
                              .description(appName),
                        )
                      : Text(
                          context.msg.main.dialer.noPermission
                              .permanentDescription(appName),
                        ),
                  icon: const Icon(VialerSans.missedCall),
                  children: <Widget>[
                    const SizedBox(height: 40),
                    StylizedButton.raised(
                      colored: true,
                      onPressed: state is NoPermission && !state.dontAskAgain
                          ? callerCubit.requestPermission
                          : callerCubit.openAppSettings,
                      child: state is NoPermission && !state.dontAskAgain
                          ? Text(
                              context
                                  .msg.main.dialer.noPermission.buttonPermission
                                  .toUpperCaseIfAndroid(context),
                            )
                          : Text(
                              context.msg.main.dialer.noPermission
                                  .buttonOpenSettings
                                  .toUpperCaseIfAndroid(context),
                            ),
                    ),
                  ],
                ),
                child: T9DialPad(
                  callButtonColor: context.brand.theme.colors.green1,
                  callButtonIcon: VialerSans.phone,
                  onCallButtonPressed: state is CanCall
                      ? (number) => _onCallButtonPressed(context, number)
                      : null,
                  controller: _dialPadController,
                  onDeleteAll: dialerCubit.clearLastCalledDestination,
                ),
              ),
            );

            return Scaffold(
              body: !widget.isInBottomNavBar
                  ? ConnectivityAlert(
                      child: body,
                    )
                  : body,
            );
          },
        ),
      ),
    );
  }
}
