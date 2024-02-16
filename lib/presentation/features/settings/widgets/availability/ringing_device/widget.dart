import 'package:flutter/material.dart';
import 'package:vialer/presentation/features/settings/widgets/availability/ringing_device/ringing_device_button.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/calling/voip/destination.dart';
import '../../../../../../../data/models/relations/user_availability_status.dart';
import '../../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../../../data/models/user/user.dart';
import '../../../../../../../data/repositories/calling/voip/destination_repository.dart';
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
    required this.isRingingDeviceOffline,
    super.key,
  });

  final User user;
  final List<Destination> destinations;
  final DestinationChangedCallback onDestinationChanged;
  final UserAvailabilityStatus userAvailabilityStatus;
  final bool enabled;
  final bool isRingingDeviceOffline;

  bool get shouldEntireWidgetBeDisabled => isRingingDeviceOffline
      ? false
      : switch (userAvailabilityStatus) {
          UserAvailabilityStatus.online ||
          UserAvailabilityStatus.availableForColleagues =>
            false,
          UserAvailabilityStatus.doNotDisturb => true,
          UserAvailabilityStatus.offline => true,
        };

  @override
  Widget build(BuildContext context) {
    final appAccount = destinations.findAppAccountFor(user: user);
    final webphoneAccount = destinations.findWebphoneAccountFor(user: user);
    final fixedDestinations = destinations.fixedDestinationsFor(user: user);
    final deskPhones = destinations.deskPhonesFor(user: user);
    final enableButtons = !shouldEntireWidgetBeDisabled && enabled;
    final showDeviceOfflineWarning = isRingingDeviceOffline;

    return Opacity(
      opacity: shouldEntireWidgetBeDisabled ? 0.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvailabilityHeader(context.msg.ua.mobile.rigingDevice.Label),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 3.5,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              if (appAccount != null)
                RingingDeviceButton(
                  RingingDeviceType.mobile,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: isRingingDeviceOffline,
                ),
              if (deskPhones.isNotEmpty)
                RingingDeviceButton(
                  RingingDeviceType.deskPhone,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: isRingingDeviceOffline,
                ),
              if (webphoneAccount != null)
                RingingDeviceButton(
                  RingingDeviceType.webphone,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: isRingingDeviceOffline,
                ),
              if (fixedDestinations.isNotEmpty)
                RingingDeviceButton(
                  RingingDeviceType.fixed,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: isRingingDeviceOffline,
                ),
            ],
          ),
          if (showDeviceOfflineWarning) _CurrentDeviceOfflineWarning(),
          MultipleRingingDeviceDropdown(
            user: user,
            destinations: destinations,
            enabled: enableButtons,
            onDestinationChanged: onDestinationChanged,
            loading: !enabled,
          ),
        ],
      ),
    );
  }
}

class _CurrentDeviceOfflineWarning extends StatelessWidget {
  const _CurrentDeviceOfflineWarning();

  @override
  Widget build(BuildContext context) {
    return _RingingDeviceWarning(
      text: context.msg.main.colleagues.status.selectedDeviceOffline,
      color: context.brand.theme.colors.userAvailabilityBusyAccent,
    );
  }
}

class _RingingDeviceWarning extends StatelessWidget {
  const _RingingDeviceWarning({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

extension UserRingingDevice on User {
  Destination get currentDestination =>
      settings.getOrNull(CallSetting.destination) != null
          ? settings.get(CallSetting.destination).asDestination()
          : Destination.unknown();

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
