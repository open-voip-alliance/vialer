import 'package:flutter/cupertino.dart';
import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';

import '../../../../../../../../domain/relations/user_availability_status.dart';
import '../../../../../../../../domain/user/user.dart';
import '../../../../../../../resources/localizations.dart';
import '../header.dart';
import 'availability_status_button.dart';

typedef StatusChangeCallback = void Function(UserAvailabilityStatus type);

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
  final UserAvailabilityStatus userAvailabilityStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvailabilityHeader(context.msg.ua.mobile.statusLabel),
        if (userAvailabilityStatus !=
            UserAvailabilityStatus.onlineWithRingingDeviceOffline)
          AvailabilityStatusButton(
            UserAvailabilityStatus.online,
            current: userAvailabilityStatus,
            enabled: enabled,
            onStatusChanged: onStatusChanged,
          ),
        if (userAvailabilityStatus ==
            UserAvailabilityStatus.onlineWithRingingDeviceOffline)
          AvailabilityStatusButton(
            UserAvailabilityStatus.onlineWithRingingDeviceOffline,
            current: userAvailabilityStatus,
            enabled: enabled,
            onStatusChanged: onStatusChanged,
          ),
        if (user.hasAppAccount || HasFeature()(Feature.userBasedDnd))
          AvailabilityStatusButton(
            UserAvailabilityStatus.doNotDisturb,
            current: userAvailabilityStatus,
            enabled: enabled,
            onStatusChanged: onStatusChanged,
          ),
        AvailabilityStatusButton(
          UserAvailabilityStatus.offline,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
        ),
      ],
    );
  }
}
