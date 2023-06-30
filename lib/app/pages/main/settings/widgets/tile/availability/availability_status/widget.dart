import 'package:flutter/cupertino.dart';
import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';

import '../../../../../../../../domain/user/user.dart';
import '../../../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../../../../resources/localizations.dart';
import '../header.dart';
import 'availability_status_button.dart';

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
        AvailabilityHeader(context.msg.ua.mobile.statusLabel),
        AvailabilityStatusButton(
          ColleagueAvailabilityStatus.available,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
        ),
        if (user.hasAppAccount || HasFeature()(Feature.userBasedDnd))
          AvailabilityStatusButton(
            ColleagueAvailabilityStatus.doNotDisturb,
            current: userAvailabilityStatus,
            enabled: enabled,
            onStatusChanged: onStatusChanged,
          ),
        AvailabilityStatusButton(
          ColleagueAvailabilityStatus.offline,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
        ),
      ],
    );
  }
}
