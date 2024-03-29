import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/widgets/availability/availability_status/widget.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/relations/user_availability_status.dart';
import '../button.dart';

class AvailabilityStatusButton extends StatelessWidget {
  const AvailabilityStatusButton(
    this.type, {
    required this.current,
    required this.enabled,
    required this.onStatusChanged,
    required this.isRingingDeviceOffline,
    super.key,
  });

  final UserAvailabilityStatus type;
  final UserAvailabilityStatus current;
  final bool enabled;
  final StatusChangeCallback onStatusChanged;
  final bool isRingingDeviceOffline;

  (String, IconData, Color, Color) _styling(BuildContext context) {
    final strings = context.msg.main.colleagues.status;
    final colors = context.brand.theme.colors;

    if (type == current && isRingingDeviceOffline && type.isOnlineOrSimilar) {
      return (
        strings.availableRingingDeviceOffline,
        FontAwesomeIcons.circleExclamation,
        colors.userAvailabilityBusyAccent,
        colors.userAvailabilityBusy,
      );
    }

    return switch (type) {
      UserAvailabilityStatus.online => (
          strings.available,
          FontAwesomeIcons.circleCheck,
          colors.userAvailabilityAvailableAccent,
          colors.userAvailabilityAvailable,
        ),
      UserAvailabilityStatus.availableForColleagues => (
          strings.availableInternally,
          FontAwesomeIcons.arrowRightArrowLeft,
          colors.userAvailabilityAvailableAccent,
          colors.userAvailabilityAvailable,
        ),
      UserAvailabilityStatus.doNotDisturb => (
          strings.doNotDisturb,
          FontAwesomeIcons.bellSlash,
          colors.userAvailabilityUnavailableAccent,
          colors.userAvailabilityUnavailable,
        ),
      UserAvailabilityStatus.offline => (
          strings.offline,
          FontAwesomeIcons.circleMinus,
          colors.userAvailabilityOfflineAccent,
          colors.userAvailabilityOffline,
        ),
    };
  }

  void _onPressed(
    BuildContext context,
    UserAvailabilityStatus type,
    String text,
  ) {
    if (enabled) {
      onStatusChanged(type);
      SemanticsService.announce(
        context.msg.main.settings.list.calling.availability.screenReader.status
            .selection(text),
        Directionality.of(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (text, icon, foregroundColor, backgroundColor) = _styling(context);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AvailabilityButton(
        text: text,
        leadingIcon: icon,
        onPressed: () => _onPressed(context, type, text),
        isActive: current == type,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

extension on UserAvailabilityStatus {
  /// There are multiple similar statuses to [UserAvailabilityStatus.online]
  /// that we want to handle in similar ways. This will return [true] if this
  /// status is any that should be considered as "online".
  bool get isOnlineOrSimilar => [
        UserAvailabilityStatus.online,
        UserAvailabilityStatus.availableForColleagues,
      ].contains(this);
}
