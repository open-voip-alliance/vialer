import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';

import '../../../../../../../dependency_locator.dart';
import '../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../domain/event/event_bus.dart';
import '../../../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../../domain/user/settings/settings.dart';
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

  @override
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>(
      // We apply a fairly long debounce time here because we need to make two
      // api requests when changing availability. This will mean we get a
      // [LoggedInUserAvailabilityChanged] event for both of them and users
      // would see their status switch briefly.
      //
      // This can be removed when do-not-disturb becomes user-based and so we
      // don't need to update the destination at the same time.
      debounceTime: const Duration(milliseconds: 3000),
      (event) {
        setState(() {
          _userAvailabilityStatus =
              event.availability.asLoggedInUserDisplayStatus();
        });
      },
    );
  }

  Future<void> _onAvailabilityStatusChange(
    User user,
    List<Destination> destinations,
    BuildContext context,
    ColleagueAvailabilityStatus requestedStatus,
  ) async {
    setState(() {
      _userAvailabilityStatus = requestedStatus;
    });

    return defaultOnSettingsChanged(
      context,
      _determineSettingsToModify(user, destinations, context, requestedStatus),
    );
  }

  Map<SettingKey, Object> _determineSettingsToModify(
    User user,
    List<Destination> destinations,
    BuildContext context,
    ColleagueAvailabilityStatus requestedStatus,
  ) {
    final appAccount = destinations.findAppAccountFor(user: user);

    switch (requestedStatus) {
      case ColleagueAvailabilityStatus.available:
        return {
          CallSetting.dnd: false,
          if (appAccount != null) CallSetting.destination: appAccount,
        };
      case ColleagueAvailabilityStatus.doNotDisturb:
        return {
          CallSetting.dnd: true,
          if (appAccount != null) CallSetting.destination: appAccount,
        };
      case ColleagueAvailabilityStatus.offline:
        return {
          CallSetting.dnd: false,
          CallSetting.destination: const Destination.notAvailable(),
        };
      case ColleagueAvailabilityStatus.busy:
      case ColleagueAvailabilityStatus.unknown:
        throw ArgumentError(
          'Only [available], [doNotDisturb], [offline] '
          'are valid options for setting user status.',
        );
    }
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
              if (state.availableDestinations.length >= 2)
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
