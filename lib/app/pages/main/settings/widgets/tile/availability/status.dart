import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../../domain/user/user.dart';
import '../../../../../../../domain/user_availability/colleagues/colleague.dart';
import 'button.dart';
import 'header.dart';

typedef StatusChangeCallback = void Function(ColleagueAvailabilityStatus type);

class AvailabilityStatusPicker extends StatelessWidget {
  const AvailabilityStatusPicker({
    required this.onStatusChanged,
    required this.user,
    required this.userAvailabilityStatus,
    this.enabled = true,
    super.key,
  });

  final StatusChangeCallback onStatusChanged;
  final User user;
  final bool enabled;
  final ColleagueAvailabilityStatus userAvailabilityStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AvailabilityHeader('Set your status'),
        AvailabilityButton(
          text: 'Available',
          leadingIcon: FontAwesomeIcons.circleCheck,
          onPressed: enabled
              ? () => onStatusChanged(ColleagueAvailabilityStatus.available)
              : null,
          isActive:
              userAvailabilityStatus == ColleagueAvailabilityStatus.available,
        ),
        AvailabilityButton(
          text: 'DND',
          leadingIcon: FontAwesomeIcons.bellSlash,
          onPressed: enabled
              ? () => onStatusChanged(ColleagueAvailabilityStatus.doNotDisturb)
              : null,
          isActive: userAvailabilityStatus ==
              ColleagueAvailabilityStatus.doNotDisturb,
        ),
        AvailabilityButton(
          text: 'Offline',
          leadingIcon: FontAwesomeIcons.circleMinus,
          onPressed: enabled
              ? () => onStatusChanged(ColleagueAvailabilityStatus.offline)
              : null,
          isActive:
              userAvailabilityStatus == ColleagueAvailabilityStatus.offline,
        ),
      ],
    );
  }
}
