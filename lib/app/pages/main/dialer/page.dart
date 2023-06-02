import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/event/event_bus.dart';
import '../../../../domain/user/get_logged_in_user.dart';
import '../../../../domain/user/settings/app_setting.dart';
import '../../../../domain/user/settings/setting_changed.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../settings/widgets/buttons/settings_button.dart';
import '../widgets/caller.dart';
import '../widgets/conditional_placeholder.dart';
import '../widgets/connectivity_alert.dart';
import '../widgets/t9_dial_pad.dart';
import 'cubit.dart';

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
          settingValue ?? user.settings.get(AppSetting.showClientCalls);
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

  void _onCallButtonPressed(BuildContext context, String number) =>
      unawaited(context.read<DialerCubit>().call(number));

  @override
  void dispose() {
    unawaited(_eventBusSubscription?.cancel());

    super.dispose();
  }

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
                              .toUpperCaseIfAndroid(context)
                          : context
                              .msg.main.dialer.noPermission.buttonOpenSettings
                              .toUpperCaseIfAndroid(context),
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
