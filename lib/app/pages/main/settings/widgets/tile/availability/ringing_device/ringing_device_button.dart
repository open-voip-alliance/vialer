import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';

import '../../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../../../resources/localizations.dart';
import '../button.dart';

class RingingDeviceButton extends StatelessWidget {
  const RingingDeviceButton(
    this.type, {
    required this.user,
    required this.enabled,
    required this.destinations,
    required this.onDestinationChanged,
    this.parentWidgetIsEnabled = true,
    super.key,
  });

  final RingingDeviceType type;
  final bool enabled;
  final DestinationChangedCallback onDestinationChanged;
  final List<Destination> destinations;
  final User user;
  final bool parentWidgetIsEnabled;

  String _text(BuildContext context) {
    switch (type) {
      case RingingDeviceType.webphone:
        return context.msg.ua.mobile.devices.webphone;
      case RingingDeviceType.deskPhone:
        return context.msg.ua.mobile.devices.deskphone;
      case RingingDeviceType.mobile:
        return context.msg.ua.mobile.devices.mobile;
      case RingingDeviceType.unknown:
      case RingingDeviceType.fixed:
        return context.msg.ua.mobile.devices.fixedDestination;
    }
  }

  IconData get _icon {
    switch (type) {
      case RingingDeviceType.webphone:
        return FontAwesomeIcons.desktop;
      case RingingDeviceType.deskPhone:
      case RingingDeviceType.unknown:
        return FontAwesomeIcons.phoneOffice;
      case RingingDeviceType.mobile:
        return FontAwesomeIcons.mobileNotch;
      case RingingDeviceType.fixed:
        return FontAwesomeIcons.phoneArrowRight;
    }
  }

  Destination? get _destination {
    switch (type) {
      case RingingDeviceType.webphone:
        return destinations.findWebphoneAccountFor(user: user);
      case RingingDeviceType.deskPhone:
      case RingingDeviceType.unknown:
        return destinations.deskPhonesFor(user: user).first;
      case RingingDeviceType.mobile:
        return destinations.findAppAccountFor(user: user);
      case RingingDeviceType.fixed:
        return destinations.fixedDestinationsFor(user: user).first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvailabilityButton(
      text: _text(context),
      leadingIcon: _icon,
      trailingIcon: user.ringingDevice == type && enabled
          ? FontAwesomeIcons.solidBellOn
          : null,
      isActive: parentWidgetIsEnabled && user.ringingDevice == type,
      onPressed: enabled
          ? () =>
              _destination != null ? onDestinationChanged(_destination!) : {}
          : null,
    );
  }
}
