import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/data/models/user/user.dart';
import 'package:vialer/global.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../data/models/event/event_bus.dart';
import '../../../../data/models/user/settings/app_setting.dart';
import '../../../../data/models/user/settings/setting_changed.dart';
import '../../../../dependency_locator.dart';
import '../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../routes.dart';
import '../../shared/widgets/caller.dart';
import '../../shared/widgets/conditional_placeholder.dart';
import '../../shared/widgets/connectivity_alert.dart';
import '../../shared/widgets/t9_dial_pad.dart';
import '../../util/widgets_binding_observer_registrar.dart';
import '../call/widgets/outgoing_number_prompt/show_prompt.dart';
import '../settings/widgets/settings_button.dart';
import 'controllers/cubit.dart';

class DialerPage extends StatefulWidget {
  const DialerPage({
    required this.isInBottomNavBar,
    super.key,
  });

  final bool isInBottomNavBar;

  @override
  State<DialerPage> createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  final _dialPadController = TextEditingController();
  final _eventBus = dependencyLocator<EventBusObserver>();
  StreamSubscription<SettingChangedEvent<Object>>? _eventBusSubscription;

  final _getUser = GetLoggedInUserUseCase();

  bool _enableT9ContactSearch = false;

  @override
  void initState() {
    super.initState();

    unawaited(_updateEnableT9ContactSearch());

    _eventBusSubscription = _eventBus.onSettingChange<bool>(
      AppSetting.enableT9ContactSearch,
      (_, newValue) {
        unawaited(_updateEnableT9ContactSearch(settingValue: newValue));
      },
    );
  }

  Future<void> _updateEnableT9ContactSearch({bool? settingValue}) async {
    final user = _getUser();

    setState(() {
      _enableT9ContactSearch =
          settingValue ?? user.settings.get(AppSetting.enableT9ContactSearch);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      final callerState = context.read<CallerCubit>().state;

      // We pop the dialer on Android if we're initiating a call-through call.
      if (Platform.isAndroid &&
          callerState is StartingCall &&
          !callerState.isVoip) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == Routes.main,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      unawaited(context.read<CallerCubit>().checkPhonePermission());
    }
  }

  void _onDialerStateChanged(BuildContext context, DialerState state) {
    if (state.lastCalledDestination != null &&
        _dialPadController.text.isEmpty) {
      _dialPadController.text = state.lastCalledDestination!;
    }
  }

  void _onCallButtonPressed(BuildContext context, String number) async {
    // If the number is empty, the user wants to fill the last selected number
    // so just forward to the cubit immediately.
    if (number.isEmpty) {
      unawaited(context.read<DialerCubit>().call(number));
      return;
    }

    showOutgoingNumberPrompt(context, number, (_) {
      unawaited(context.read<DialerCubit>().call(number));
    });
  }

  @override
  void dispose() {
    unawaited(_eventBusSubscription?.cancel());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _populateNumberFromRouteArgument(context);

    return BlocProvider<DialerCubit>(
      create: (context) => DialerCubit(context.read<CallerCubit>()),
      child: BlocListener<DialerCubit, DialerState>(
        listener: _onDialerStateChanged,
        child: BlocBuilder<CallerCubit, CallerState>(
          builder: (context, state) {
            final appName = context.brand.appName;
            final callerCubit = context.watch<CallerCubit>();
            final dialerCubit = context.watch<DialerCubit>();

            final body = Semantics(
              explicitChildNodes: true,
              container: true,
              label: context.msg.main.dialer.screenReader.title,
              child: SafeArea(
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
                    icon: const FaIcon(FontAwesomeIcons.phoneXmark),
                    children: <Widget>[
                      const SizedBox(height: 40),
                      SettingsButton(
                        onPressed: state is NoPermission && !state.dontAskAgain
                            ? callerCubit.requestPermission
                            : callerCubit.openAppSettings,
                        text: state is NoPermission && !state.dontAskAgain
                            ? context
                                .msg.main.dialer.noPermission.buttonPermission
                            : context.msg.main.dialer.noPermission
                                .buttonOpenSettings,
                      ),
                    ],
                  ),
                  child: T9DialPad(
                    callButtonColor: context.brand.theme.colors.green1,
                    callButtonIcon: FontAwesomeIcons.solidPhone,
                    callButtonSemanticsHint: context.msg.generic.button.call,
                    onCallButtonPressed: state is CanCall
                        ? (number) => _onCallButtonPressed(context, number)
                        : null,
                    controller: _dialPadController,
                    onDeleteAll: dialerCubit.clearLastCalledDestination,
                    isT9ContactSearchEnabled: _enableT9ContactSearch,
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
          },
        ),
      ),
    );
  }

  /// Allows the dialer to be called with a [String] route argument, and will
  /// automatically populate the phone number. This is primarily useful when
  /// trying to start a Vialer call from outside the app.
  void _populateNumberFromRouteArgument(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;

    if (argument == null || argument is! String) return;

    if (argument.isBlank) return;

    track('dialer-populated-from-external-app');
    _dialPadController.text = argument;
  }
}
