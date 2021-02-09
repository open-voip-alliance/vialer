import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/brand.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/connectivity_checker.dart';
import '../../../widgets/stylized_button.dart';
import '../../../widgets/transparent_status_bar.dart';
import '../widgets/caller.dart';
import '../widgets/caller/state.dart';
import '../widgets/conditional_placeholder.dart';
import '../widgets/connectivity_alert.dart';
import 'cubit.dart';
import 'widgets/key_input.dart';
import 'widgets/keypad.dart';
import 'widgets/t9/widget.dart';

class DialerPage extends StatefulWidget {
  final bool isInBottomNavBar;

  const DialerPage({
    Key key,
    @required this.isInBottomNavBar,
  }) : super(key: key);

  @override
  _DialerPageState createState() => _DialerPageState();
}

// ignore: prefer_mixin
class _DialerPageState extends State<DialerPage> with WidgetsBindingObserver {
  final _keypadController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final callerState = context.read<CallerCubit>().state;

      // We pop the dialer on Android if we're initiating a call.
      if (Platform.isAndroid && callerState is InitiatingCall) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == Routes.main,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      context.read<CallerCubit>().checkCallPermissionIfNotVoip();
    }
  }

  void _onDialerStateChanged(BuildContext context, DialerState state) {
    if (state.lastCalledDestination != null && _keypadController.text.isEmpty) {
      _keypadController.text = state.lastCalledDestination;
    }
  }

  void _call(BuildContext context) {
    context.read<DialerCubit>().call(_keypadController.text);
    _keypadController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var body = TransparentStatusBar(
      brightness: Brightness.dark,
      child: BlocProvider<DialerCubit>(
        create: (context) => DialerCubit(context.read<CallerCubit>()),
        child: BlocListener<DialerCubit, DialerState>(
          listener: _onDialerStateChanged,
          child: BlocBuilder<CallerCubit, CallerState>(
            builder: (context, state) {
              final callerCubit = context.watch<CallerCubit>();
              final dialerCubit = context.watch<DialerCubit>();
              final appName = Provider.of<Brand>(context).appName;

              return SafeArea(
                child: ConditionalPlaceholder(
                  showPlaceholder: state is NoPermission,
                  placeholder: Warning(
                    title: Text(context.msg.main.dialer.noPermission.title),
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
                                context.msg.main.dialer.noPermission
                                    .buttonPermission
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
                  child: Column(
                    children: <Widget>[
                      if (context.isAndroid) ...[
                        T9ContactsListView(controller: _keypadController),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                      ] else if (context.isIOS)
                        const SafeArea(
                          child: SizedBox(
                            height: 48,
                          ),
                        ),
                      Material(
                        child: KeyInput(
                          controller: _keypadController,
                        ),
                      ),
                      if (context.isIOS) const SizedBox(height: 24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: BlocBuilder<ConnectivityCheckerCubit,
                                ConnectivityState>(
                              builder: (context, state) {
                                return Keypad(
                                  controller: _keypadController,
                                  onCallButtonPressed: state is Connected
                                      ? () => _call(context)
                                      : null,
                                  onDeleteButtonPressed: state is Connected
                                      ? dialerCubit.clearLastCalledDestination
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }
}
