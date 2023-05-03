import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/status.dart';

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

class AvailabilitySwitcher extends StatefulWidget {
  const AvailabilitySwitcher({
    super.key,
  });

  @override
  State<AvailabilitySwitcher> createState() => _AvailabilitySwitcherState();
}

class _AvailabilitySwitcherState extends State<AvailabilitySwitcher> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  var _userAvailabilityStatus = ColleagueAvailabilityStatus.available;

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

    setState(() {
      _userAvailabilityStatus = requestedStatus;
    });

    switch (requestedStatus) {
      case ColleagueAvailabilityStatus.available:
        return defaultOnSettingsChanged(context, {
          CallSetting.dnd: false,
          CallSetting.destination: appAccount!,
        });
      case ColleagueAvailabilityStatus.doNotDisturb:
        return defaultOnSettingsChanged(context, {
          CallSetting.dnd: true,
          CallSetting.destination: appAccount!,
        });
      case ColleagueAvailabilityStatus.offline:
        return defaultOnSettingsChanged(context, {
          CallSetting.dnd: false,
          CallSetting.destination: const Destination.notAvailable(),
        });
      case ColleagueAvailabilityStatus.busy:
      case ColleagueAvailabilityStatus.unknown:
        throw ArgumentError(
          'Only [available], [doNotDisturb], [offline] '
          'are valid options for setting user status.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final user = state.user;
        final showDnd = state.showDnd;
        final userNumber = state.userNumber;
        final destinations = state.availableDestinations;
        final cubit = context.watch<SettingsCubit>();

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
                    user,
                    destinations,
                    context,
                    status,
                  ),
                  user: user,
                  enabled: state.shouldAllowRemoteSettings,
                  userAvailabilityStatus: _userAvailabilityStatus,
                ),
              ),
              RingingDevice(
                user: user,
                destinations: destinations,
                onDestinationChanged: (destination) async =>
                    defaultOnSettingChanged(
                  context,
                  CallSetting.destination,
                  destination,
                ),
                enabled: state.shouldAllowRemoteSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}
