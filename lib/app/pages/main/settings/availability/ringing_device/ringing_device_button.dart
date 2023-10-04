import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/availability/ringing_device/widget.dart';

import '../../../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../button.dart';

class RingingDeviceButton extends StatelessWidget {
  const RingingDeviceButton(
    this.type, {
    required this.user,
    required this.enabled,
    required this.destinations,
    required this.onDestinationChanged,
    required this.isRingingDeviceOffline,
    this.parentWidgetIsEnabled = true,
    super.key,
  });

  final RingingDeviceType type;
  final bool enabled;
  final DestinationChangedCallback onDestinationChanged;
  final List<Destination> destinations;
  final User user;
  final bool parentWidgetIsEnabled;
  final bool isRingingDeviceOffline;

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

  List<Destination?> get _destinations => switch (type) {
        RingingDeviceType.webphone => [
            destinations.findWebphoneAccountFor(user: user)
          ],
        RingingDeviceType.deskPhone ||
        RingingDeviceType.unknown =>
          destinations.deskPhonesFor(user: user),
        RingingDeviceType.mobile => [
            destinations.findAppAccountFor(user: user)
          ],
        RingingDeviceType.fixed =>
          destinations.fixedDestinationsFor(user: user),
      };

  Destination? get _destination {
    final destination = _destinations
        .whereNotNull()
        .where((destination) => destination.isOnline)
        .firstOrNull;

    return destination != null ? destination : _destinations.firstOrNull;
  }

  IconData? get _trailingIcon {
    if (!_isAtLeastOneDestinationOnline) {
      return FontAwesomeIcons.solidTriangleExclamation;
    }

    if (user.ringingDevice != type || !enabled) return null;

    return isRingingDeviceOffline
        ? FontAwesomeIcons.solidTriangleExclamation
        : FontAwesomeIcons.solidBellOn;
  }

  bool get _isAtLeastOneDestinationOnline => _destinations.any(
        (destination) =>
            destination is PhoneAccount ? destination.isOnline : true,
      );

  void _onPressed(
    BuildContext context,
  ) {
    if (enabled && _isAtLeastOneDestinationOnline && _destination != null) {
      onDestinationChanged(_destination!);
      SemanticsService.announce(
        '${_text(context)} was selected to receive calls', //wip add localized String
        Directionality.of(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvailabilityButton(
      text: _text(context),
      leadingIcon: _icon,
      trailingIcon: _trailingIcon,
      isActive: parentWidgetIsEnabled && user.ringingDevice == type,
      onPressed: () => _onPressed(context),
      backgroundColor: isRingingDeviceOffline
          ? context.brand.theme.colors.userAvailabilityBusy
          : null,
      foregroundColor: isRingingDeviceOffline
          ? context.brand.theme.colors.userAvailabilityBusyAccent
          : null,
      isDestinationOnline: _isAtLeastOneDestinationOnline,
    );
  }
}
