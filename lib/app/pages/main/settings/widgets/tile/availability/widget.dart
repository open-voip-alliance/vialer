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
    final appAccount = destinations.findAppAccountFor(user: user);

    assert(
      appAccount != null,
      "Users without an app account shouldn't be able to change this.",
    );

    final destination =
        context.read<SettingsCubit>().storage.lastRingingDevice ??
            destinations.findHighestPriorityDestinationFor(user: user);

    return switch (requestedStatus) {
      ColleagueAvailabilityStatus.available => {
          CallSetting.dnd: false,
          if (destination != null) CallSetting.destination: destination,
        },
      ColleagueAvailabilityStatus.doNotDisturb => {
          CallSetting.dnd: true,
          // While DND is account based, enabling it should always point the
          // user back to the app account otherwise it will have no effect.
          if (appAccount != null) CallSetting.destination: appAccount,
        },
      ColleagueAvailabilityStatus.offline => {
          CallSetting.dnd: false,
          CallSetting.destination: const Destination.notAvailable(),
        },
      _ => throw ArgumentError(
          'Only [available], [doNotDisturb], [offline] '
          'are valid options for setting user status.',
        ),
    };
  }

  Future<void> _onDestinationChanged(Destination destination) async {
    await defaultOnSettingChanged(
      context,
      CallSetting.destination,
      destination,
    );

    if (destination is PhoneAccount || destination is PhoneNumber) {
      context.read<SettingsCubit>().storage.lastRingingDevice = destination;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return UserAvailabilityStatusBuilder(
          user: state.user,
          builder: (_, status) {
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
                      onDestinationChanged: _onDestinationChanged,
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
