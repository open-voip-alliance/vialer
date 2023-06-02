import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/availability_status/widget.dart';

import '../../../../../../../../domain/user_availability/colleagues/colleague.dart';
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

  final ColleagueAvailabilityStatus type;
  final ColleagueAvailabilityStatus current;
  final bool enabled;
  final StatusChangeCallback onStatusChanged;

  String _text(BuildContext context) {
    switch (type) {
      case ColleagueAvailabilityStatus.available:
      case ColleagueAvailabilityStatus.busy:
        return context.msg.main.colleagues.status.available;
      case ColleagueAvailabilityStatus.doNotDisturb:
        return context.msg.main.colleagues.status.doNotDisturb;
      case ColleagueAvailabilityStatus.unknown:
      case ColleagueAvailabilityStatus.offline:
        return context.msg.main.colleagues.status.offline;
    }
  }

  IconData get _icon {
    switch (type) {
      case ColleagueAvailabilityStatus.available:
      case ColleagueAvailabilityStatus.busy:
        return FontAwesomeIcons.circleCheck;
      case ColleagueAvailabilityStatus.doNotDisturb:
        return FontAwesomeIcons.bellSlash;
      case ColleagueAvailabilityStatus.unknown:
      case ColleagueAvailabilityStatus.offline:
        return FontAwesomeIcons.circleMinus;
    }
  }

  Color _foregroundColor(BuildContext context) {
    switch (type) {
      case ColleagueAvailabilityStatus.available:
      case ColleagueAvailabilityStatus.busy:
        return context.brand.theme.colors.userAvailabilityAvailableAccent;
      case ColleagueAvailabilityStatus.doNotDisturb:
        return context.brand.theme.colors.userAvailabilityUnavailableAccent;
      case ColleagueAvailabilityStatus.unknown:
      case ColleagueAvailabilityStatus.offline:
        return context.brand.theme.colors.userAvailabilityOfflineAccent;
    }
  }

  Color _backgroundColor(BuildContext context) {
    switch (type) {
      case ColleagueAvailabilityStatus.available:
      case ColleagueAvailabilityStatus.busy:
        return context.brand.theme.colors.userAvailabilityAvailable;
      case ColleagueAvailabilityStatus.doNotDisturb:
        return context.brand.theme.colors.userAvailabilityUnavailable;
      case ColleagueAvailabilityStatus.unknown:
      case ColleagueAvailabilityStatus.offline:
        return context.brand.theme.colors.userAvailabilityOffline;
    }
  }

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
