import 'package:flutter/material.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/ringing_device_button.dart';

import '../../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../../../../resources/localizations.dart';
import '../header.dart';
import 'multiple_ringing_device_dropdown.dart';

typedef DestinationChangedCallback = void Function(Destination destination);

class RingingDevice extends StatelessWidget {
  const RingingDevice({
    required this.user,
    required this.destinations,
    required this.onDestinationChanged,
    required this.userAvailabilityStatus,
    this.enabled = true,
    super.key,
  });

  final User user;
  final List<Destination> destinations;
  final DestinationChangedCallback onDestinationChanged;
  final ColleagueAvailabilityStatus userAvailabilityStatus;
  final bool enabled;

  bool get shouldEntireWidgetBeDisabled =>
      userAvailabilityStatus == ColleagueAvailabilityStatus.offline ||
      userAvailabilityStatus == ColleagueAvailabilityStatus.doNotDisturb;

  @override
  Widget build(BuildContext context) {
    final appAccount = destinations.findAppAccountFor(user: user);
    final webphoneAccount = destinations.findWebphoneAccountFor(user: user);
    final fixedDestinations = destinations.fixedDestinationsFor(user: user);
    final deskPhones = destinations.deskPhonesFor(user: user);
    final enableButtons = !shouldEntireWidgetBeDisabled && enabled;

    return Opacity(
      opacity: shouldEntireWidgetBeDisabled ? 0.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvailabilityHeader(context.msg.main.ua.mobile.ringingDevice.label),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 3.5,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              if (webphoneAccount != null)
                RingingDeviceButton(
                  RingingDeviceType.webphone,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                ),
              if (deskPhones.isNotEmpty)
                RingingDeviceButton(
                  RingingDeviceType.deskPhone,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                ),
              if (appAccount != null)
                RingingDeviceButton(
                  RingingDeviceType.mobile,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                ),
              if (fixedDestinations.isNotEmpty)
                RingingDeviceButton(
                  RingingDeviceType.fixed,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                ),
            ],
          ),
          MultipleRingingDeviceDropdown(
            user: user,
            destinations: destinations,
            enabled: enableButtons,
            onDestinationChanged: onDestinationChanged,
          ),
        ],
      ),
    );
  }
}

extension UserRingingDevice on User {
  Destination get currentDestination => settings.get(CallSetting.destination);

  RingingDeviceType get ringingDevice {
    return currentDestination.map(
      unknown: (_) => RingingDeviceType.unknown,
      notAvailable: (_) => RingingDeviceType.unknown,
      phoneNumber: (_) => RingingDeviceType.fixed,
      phoneAccount: (phoneAccount) {
        if (phoneAccount.id.toString() == appAccountId) {
          return RingingDeviceType.mobile;
        }
        if (phoneAccount.id.toString() == webphoneAccountId) {
          return RingingDeviceType.webphone;
        }
        return RingingDeviceType.deskPhone;
      },
    );
  }
}

enum RingingDeviceType {
  unknown,
  webphone,
  deskPhone,
  mobile,
  fixed,
}
