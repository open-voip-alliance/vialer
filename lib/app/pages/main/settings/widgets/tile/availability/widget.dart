import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';

import '../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../../domain/user/settings/settings.dart';
import '../../../../../../../domain/user/user.dart';
import '../../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../widgets/user_availability_status_builder.dart';
import '../../../cubit.dart';
import '../value.dart';
import '../widget.dart';
import 'availability_status/widget.dart';

class AvailabilitySwitcher extends StatefulWidget {
  const AvailabilitySwitcher({super.key});

  @override
  State<AvailabilitySwitcher> createState() => _AvailabilitySwitcherState();
}

class _AvailabilitySwitcherState extends State<AvailabilitySwitcher> {
  /// We want the UI to be optimistic, rather than waiting for a server response
  /// before changing the status. We set this temporarily while making changes
  /// to immediately update the UI with the user's choice.
  ColleagueAvailabilityStatus? _statusOverride;

  Future<void> _onAvailabilityStatusChange(
    User user,
    List<Destination> destinations,
    BuildContext context,
    ColleagueAvailabilityStatus requestedStatus,
  ) async {
    setState(() {
      _statusOverride = requestedStatus;
    });

    await defaultOnSettingsChanged(
      context,
      _determineSettingsToModify(user, destinations, context, requestedStatus),
    );
    _statusOverride = null;
  }

  Map<SettingKey, Object> _determineSettingsToModify(
    User user,
    List<Destination> destinations,
    BuildContext context,
    ColleagueAvailabilityStatus requestedStatus,
  ) {
    final destination =
        destinations.findHighestPriorityDestinationFor(user: user);

    switch (requestedStatus) {
      case ColleagueAvailabilityStatus.available:
        return {
          CallSetting.dnd: false,
          if (destination != null) CallSetting.destination: destination,
        };
      case ColleagueAvailabilityStatus.doNotDisturb:
        return {
          CallSetting.dnd: true,
          if (destination != null) CallSetting.destination: destination,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return UserAvailabilityStatusBuilder(
          builder: (context, status) {
            final userStatus = _statusOverride ?? status;
            return SettingTile(
              padding: EdgeInsets.zero,
              mergeSemantics: false,
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
                      userAvailabilityStatus: userStatus,
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
                      userAvailabilityStatus: userStatus,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
