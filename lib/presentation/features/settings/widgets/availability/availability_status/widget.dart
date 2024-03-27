import 'package:flutter/cupertino.dart';

import '../../../../../../../data/models/relations/user_availability_status.dart';
import '../../../../../../../data/models/user/user.dart';
import '../../../../../resources/localizations.dart';
import '../header.dart';
import 'availability_status_button.dart';

typedef StatusChangeCallback = void Function(UserAvailabilityStatus type);

class AvailabilityStatusPicker extends StatelessWidget {
  const AvailabilityStatusPicker({
    required this.onStatusChanged,
    required this.user,
    required this.userAvailabilityStatus,
    this.enabled = true,
    required this.isRingingDeviceOffline,
    super.key,
  });

  final StatusChangeCallback onStatusChanged;
  final User user;
  final bool enabled;
  final UserAvailabilityStatus userAvailabilityStatus;
  final bool isRingingDeviceOffline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvailabilityHeader(context.msg.ua.mobile.statusLabel),
        AvailabilityStatusButton(
          UserAvailabilityStatus.online,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
          isRingingDeviceOffline: isRingingDeviceOffline,
        ),
        AvailabilityStatusButton(
          UserAvailabilityStatus.availableForColleagues,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
          isRingingDeviceOffline: isRingingDeviceOffline,
        ),
        AvailabilityStatusButton(
          UserAvailabilityStatus.doNotDisturb,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
          isRingingDeviceOffline: isRingingDeviceOffline,
        ),
        AvailabilityStatusButton(
          UserAvailabilityStatus.offline,
          current: userAvailabilityStatus,
          enabled: enabled,
          onStatusChanged: onStatusChanged,
          isRingingDeviceOffline: isRingingDeviceOffline,
        ),
      ],
    );
  }
}
