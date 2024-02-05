import 'package:flutter/cupertino.dart';
import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';

import '../../../../../../../../domain/relations/user_availability_status.dart';
import '../../../../../../../../domain/user/user.dart';
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

  // Rollout of new statuses requires some coordination between different
  // products, we are going to handle our feature flag not being enabled by
  // at least showing this status if we receive it from the server but they
  // won't be able to change to it or change back.
  //
  // This can be removed at a later date.
  bool get _shouldShowAvailableForColleaguesButton =>
      hasFeature(Feature.setAvailableForColleaguesStatus) ||
      userAvailabilityStatus == UserAvailabilityStatus.availableForColleagues;

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
        if (_shouldShowAvailableForColleaguesButton)
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
