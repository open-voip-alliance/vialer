import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/widgets/availability/ringing_device/widget.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/calling/voip/destination.dart';
import '../../../../../../../data/models/user/user.dart';
import '../../../../../util/stylized_snack_bar.dart';
import '../button.dart';

class RingingDeviceButton extends StatefulWidget {
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

  @override
  State<RingingDeviceButton> createState() => _RingingDeviceButtonState();
}

class _RingingDeviceButtonState extends State<RingingDeviceButton> {
  bool _isWarningAboutOfflineRingingDevice = false;

  String _text(BuildContext context) {
    switch (widget.type) {
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
    switch (widget.type) {
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

  List<Destination?> get _destinations => switch (widget.type) {
        RingingDeviceType.webphone => [
            widget.destinations.findWebphoneAccountFor(user: widget.user),
          ],
        RingingDeviceType.deskPhone ||
        RingingDeviceType.unknown =>
          widget.destinations.deskPhonesFor(user: widget.user),
        RingingDeviceType.mobile => [
            widget.destinations.findAppAccountFor(user: widget.user),
          ],
        RingingDeviceType.fixed =>
          widget.destinations.fixedDestinationsFor(user: widget.user),
      };

  Destination? get _destination {
    final destination = _destinations
        .whereNotNull()
        .where((destination) => destination.isOnline)
        .firstOrNull;

    return destination != null ? destination : _destinations.firstOrNull;
  }

  IconData? get _trailingIcon {
    if (_isWarningAboutOfflineRingingDevice) {
      return FontAwesomeIcons.solidTriangleExclamation;
    }

    if (widget.user.ringingDevice != widget.type || !widget.enabled)
      return null;

    return widget.isRingingDeviceOffline
        ? FontAwesomeIcons.solidTriangleExclamation
        : FontAwesomeIcons.solidBellOn;
  }

  bool get _isAtLeastOneDestinationOnline => _destinations.any(
        (destination) =>
            destination is PhoneAccount ? destination.isOnline : true,
      );

  Timer? _timer;

  bool get _isCurrentUserDestination =>
      widget.user.ringingDevice == widget.type;

  Future<void> _showSelectedRingingDeviceOfflineWarning(
    BuildContext context,
  ) async {
    if (_timer != null) _timer?.cancel();

    if (!_isWarningAboutOfflineRingingDevice) {
      ScaffoldMessenger.of(context).clearSnackBars();
      _presentWarningSnackBar(context);
    }

    setState(() => _isWarningAboutOfflineRingingDevice = true);

    _timer = Timer(const Duration(seconds: 4), () {
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() => _isWarningAboutOfflineRingingDevice = false);
    });
  }

  void _presentWarningSnackBar(BuildContext context) {
    showSnackBar(
      context,
      // Setting a high duration as we will manually cancel this, but this will
      // make sure it doesn't hang around if something goes wrong.
      duration: Duration(minutes: 1),
      icon: FaIcon(
        FontAwesomeIcons.solidTriangleExclamation,
        size: 22,
        color: context.brand.theme.colors.primaryDark,
      ),
      label: Text(
        context.msg.main.colleagues.status.aDeviceIsOffline(_text(context)),
        style: TextStyle(
          color: context.brand.theme.colors.primaryDark,
          fontSize: 14,
        ),
      ),
      backgroundColor: context.brand.theme.colors.primaryLight,
      contentPadding: EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _onPressed(BuildContext context) {
    if (!_isAtLeastOneDestinationOnline) {
      _showSelectedRingingDeviceOfflineWarning(context);
      return;
    }

    if (widget.enabled) {
      widget.onDestinationChanged(_destination!);
      SemanticsService.announce(
        context.msg.main.settings.list.calling.availability.screenReader
            .ringingDevice
            .selection(_text(context)),
        Directionality.of(context),
      );
    }
  }

  Color? _backgroundColor(BuildContext context) {
    if (widget.isRingingDeviceOffline && _isCurrentUserDestination) {
      return context.brand.theme.colors.userAvailabilityBusy;
    }

    if (!_isAtLeastOneDestinationOnline) {
      return context.brand.theme.colors.userAvailabilityUnknown;
    }

    return null;
  }

  Color? _foregroundColor(BuildContext context) {
    if (widget.isRingingDeviceOffline && _isCurrentUserDestination) {
      return context.brand.theme.colors.userAvailabilityBusyAccent;
    }

    if (!_isAtLeastOneDestinationOnline) {
      return context.brand.theme.colors.disabledText;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AvailabilityButton(
      text: _text(context),
      leadingIcon: _icon,
      trailingIcon: _trailingIcon,
      isActive: widget.parentWidgetIsEnabled && _isCurrentUserDestination,
      onPressed: () => _onPressed(context),
      backgroundColor: _backgroundColor(context),
      foregroundColor: _foregroundColor(context),
      disabledBackgroundColor: _backgroundColor(context),
      disabledForegroundColor: _foregroundColor(context),
      isDestinationOnline: _isAtLeastOneDestinationOnline,
    );
  }
}
