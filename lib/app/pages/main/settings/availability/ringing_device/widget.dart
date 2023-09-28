import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/availability/ringing_device/ringing_device_button.dart';

import '../../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../../domain/relations/user_availability_status.dart';
import '../../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../header.dart';
import 'multiple_ringing_device_dropdown.dart';
import '../../../../../resources/theme.dart';

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
  final UserAvailabilityStatus userAvailabilityStatus;
  final bool enabled;

  bool get shouldEntireWidgetBeDisabled => switch (userAvailabilityStatus) {
        UserAvailabilityStatus.online => false,
        UserAvailabilityStatus.onlineWithRingingDeviceOffline => false,
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
    final showDeviceOfflineWarning = userAvailabilityStatus ==
        UserAvailabilityStatus.onlineWithRingingDeviceOffline;
    final showSomeDevicesOfflineWarning =
        destinations.areSomeRingingDevicesOffline(user);

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
                  isRingingDeviceOffline: userAvailabilityStatus ==
                      UserAvailabilityStatus.onlineWithRingingDeviceOffline,
                ),
              if (deskPhones.isNotEmpty)
                RingingDeviceButton(
                  RingingDeviceType.deskPhone,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: userAvailabilityStatus ==
                      UserAvailabilityStatus.onlineWithRingingDeviceOffline,
                ),
              if (webphoneAccount != null)
                RingingDeviceButton(
                  RingingDeviceType.webphone,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: userAvailabilityStatus ==
                      UserAvailabilityStatus.onlineWithRingingDeviceOffline,
                ),
              if (fixedDestinations.isNotEmpty)
                RingingDeviceButton(
                  RingingDeviceType.fixed,
                  user: user,
                  enabled: enableButtons,
                  destinations: destinations,
                  onDestinationChanged: onDestinationChanged,
                  parentWidgetIsEnabled: !shouldEntireWidgetBeDisabled,
                  isRingingDeviceOffline: userAvailabilityStatus ==
                      UserAvailabilityStatus.onlineWithRingingDeviceOffline,
                ),
            ],
          ),
          if (showDeviceOfflineWarning) _CurrentDeviceOfflineWarning(),
          if (showSomeDevicesOfflineWarning && !showDeviceOfflineWarning)
            _SomeDevicesOfflineWarning(),
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

class _SomeDevicesOfflineWarning extends StatelessWidget {
  const _SomeDevicesOfflineWarning();

  @override
  Widget build(BuildContext context) {
    return _RingingDeviceWarning(
      text: context.msg.main.colleagues.status.someDevicesOffline,
      color: context.brand.theme.colors.grey6,
      icon: FaIcon(
        FontAwesomeIcons.solidTriangleExclamation,
        size: 16,
        color: context.brand.theme.colors.red1,
      ),
    );
  }
}

class _RingingDeviceWarning extends StatelessWidget {
  const _RingingDeviceWarning({
    required this.text,
    required this.color,
    this.icon,
  });

  final String text;
  final Color color;
  final FaIcon? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: 10),
          ],
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
      settings.getOrNull(CallSetting.destination) ?? Destination.unknown();

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

extension on List<Destination> {
  /// Returns TRUE if a ringing device is not selectable because it is offline.
  /// For ringing devices with multiple options, they must all be offline.
  bool areSomeRingingDevicesOffline(User user) {
    final appAccount = findAppAccountFor(user: user);
    final webphoneAccount = findWebphoneAccountFor(user: user);
    final fixedDestinations = fixedDestinationsFor(user: user);
    final deskPhones = deskPhonesFor(user: user);

    return [
      if (appAccount != null) appAccount.isOnline,
      if (webphoneAccount != null) webphoneAccount.isOnline,
      fixedDestinations.isAtLeastOneOnline,
      deskPhones.isAtLeastOneOnline,
    ].any((element) => !element);
  }

  bool get isAtLeastOneOnline => any((destination) => destination.isOnline);
}
