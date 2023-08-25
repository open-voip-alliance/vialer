import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/availability_status/widget.dart';

import '../../../../../../../../domain/relations/user_availability_status.dart';
import '../../../../../../../resources/localizations.dart';
import '../../../../../../../resources/theme.dart';
import '../button.dart';

class AvailabilityStatusButton extends StatelessWidget {
  const AvailabilityStatusButton(
    this.type, {
    required this.current,
    required this.enabled,
    required this.onStatusChanged,
    super.key,
  });

  final UserAvailabilityStatus type;
  final UserAvailabilityStatus current;
  final bool enabled;
  final StatusChangeCallback onStatusChanged;

  String _text(BuildContext context) => switch (type) {
        UserAvailabilityStatus.online =>
          context.msg.main.colleagues.status.available,
        UserAvailabilityStatus.onlineWithRingingDeviceOffline =>
          context.msg.main.colleagues.status.availableRingingDeviceOffline,
        UserAvailabilityStatus.doNotDisturb =>
          context.msg.main.colleagues.status.doNotDisturb,
        _ => context.msg.main.colleagues.status.offline,
      };

  IconData get _icon => switch (type) {
        UserAvailabilityStatus.online => FontAwesomeIcons.circleCheck,
        UserAvailabilityStatus.onlineWithRingingDeviceOffline =>
          FontAwesomeIcons.circleExclamation,
        UserAvailabilityStatus.doNotDisturb => FontAwesomeIcons.bellSlash,
        _ => FontAwesomeIcons.circleMinus,
      };

  Color _foregroundColor(BuildContext context) => switch (type) {
        UserAvailabilityStatus.online =>
          context.brand.theme.colors.userAvailabilityAvailableAccent,
        UserAvailabilityStatus.onlineWithRingingDeviceOffline =>
          context.brand.theme.colors.userAvailabilityBusyAccent,
        UserAvailabilityStatus.doNotDisturb =>
          context.brand.theme.colors.userAvailabilityUnavailableAccent,
        _ => context.brand.theme.colors.userAvailabilityOfflineAccent,
      };

  Color _backgroundColor(BuildContext context) => switch (type) {
        UserAvailabilityStatus.online =>
          context.brand.theme.colors.userAvailabilityAvailable,
        UserAvailabilityStatus.onlineWithRingingDeviceOffline =>
          context.brand.theme.colors.userAvailabilityBusy,
        UserAvailabilityStatus.doNotDisturb =>
          context.brand.theme.colors.userAvailabilityUnavailable,
        _ => context.brand.theme.colors.userAvailabilityOffline,
      };

  @override
  Widget build(BuildContext context) {
    return AvailabilityButton(
      text: _text(context),
      leadingIcon: _icon,
      onPressed: enabled ? () => onStatusChanged(type) : null,
      isActive: current == type,
      foregroundColor: _foregroundColor(context),
      backgroundColor: _backgroundColor(context),
    );
  }
}
