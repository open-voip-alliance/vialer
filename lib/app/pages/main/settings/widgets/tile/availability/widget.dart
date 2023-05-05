import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';

import '../../../../../../../dependency_locator.dart';
import '../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../domain/event/event_bus.dart';
import '../../../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../../domain/user/user.dart';
import '../../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../cubit.dart';
import '../../../header/widget.dart';
import '../value.dart';
import '../widget.dart';
import 'availability_status/widget.dart';

class AvailabilitySwitcher extends StatefulWidget {
  const AvailabilitySwitcher({super.key});

  @override
  State<AvailabilitySwitcher> createState() => _AvailabilitySwitcherState();
}

class _AvailabilitySwitcherState extends State<AvailabilitySwitcher> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  ColleagueAvailabilityStatus? _userAvailabilityStatus;
  var _isProcessingChanges = false;

  @override
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>((event) {
      setState(() {
        _userAvailabilityStatus =
            event.availability.asLoggedInUserDisplayStatus();
      });
    });
  }

  Future<void> _onAvailabilityStatusChange(
    User user,
    List<Destination> destinations,
    BuildContext context,
    ColleagueAvailabilityStatus requestedStatus,
  ) async {
    final appAccount = destinations.findAppAccountFor(user: user);

    if (_isProcessingChanges) return;

    setState(() {
      _userAvailabilityStatus = requestedStatus;
    });

    _isProcessingChanges = true;

    late Future<void> future;

    switch (requestedStatus) {
      case ColleagueAvailabilityStatus.available:
        future = defaultOnSettingsChanged(context, {
          CallSetting.dnd: false,
          if (appAccount != null) CallSetting.destination: appAccount,
        });
        break;
      case ColleagueAvailabilityStatus.doNotDisturb:
        future = defaultOnSettingsChanged(context, {
          CallSetting.dnd: true,
          if (appAccount != null) CallSetting.destination: appAccount,
        });
        break;
      case ColleagueAvailabilityStatus.offline:
        future = defaultOnSettingsChanged(context, {
          CallSetting.dnd: false,
          CallSetting.destination: const Destination.notAvailable(),
        });
        break;
      case ColleagueAvailabilityStatus.busy:
      case ColleagueAvailabilityStatus.unknown:
        throw ArgumentError(
          'Only [available], [doNotDisturb], [offline] '
          'are valid options for setting user status.',
        );
    }

    await future;
    _isProcessingChanges = false;
  }

  /// We get the [ColleagueAvailabilityStatus] from a websocket, if this
  /// websocket is down or not available we'll use this fallback instead at the
  /// expense of accuracy.
  ColleagueAvailabilityStatus _fallbackAvailabilityStatus(User user) {
    if (user.settings.getOrNull(CallSetting.dnd) ?? false) {
      return ColleagueAvailabilityStatus.doNotDisturb;
    }

    final destination = user.settings.getOrNull(CallSetting.destination);

    return destination is NotAvailable
        ? ColleagueAvailabilityStatus.offline
        : ColleagueAvailabilityStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (_, __) => !_isProcessingChanges,
      builder: (context, state) {
        final availabilityStatus =
            _userAvailabilityStatus ?? _fallbackAvailabilityStatus(state.user);

        return SettingTile(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AvailabilityStatusPicker(
                  onStatusChanged: (status) async =>
                      _onAvailabilityStatusChange(
                    state.user,
                    state.availableDestinations,
                    context,
                    status,
                  ),
                  user: state.user,
                  enabled: state.shouldAllowRemoteSettings,
                  userAvailabilityStatus: availabilityStatus,
                ),
              ),
              RingingDevice(
                user: state.user,
                destinations: state.availableDestinations,
                onDestinationChanged: (destination) async =>
                    defaultOnSettingChanged(
                  context,
                  CallSetting.destination,
                  destination,
                ),
                enabled: state.shouldAllowRemoteSettings,
                userAvailabilityStatus: availabilityStatus,
              ),
            ],
          ),
        );
      },
    );
  }
}
