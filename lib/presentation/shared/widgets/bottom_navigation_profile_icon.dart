import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/widgets/user_availability_status_builder/widget.dart';

import '../../../data/models/relations/user_availability_status.dart';

class BottomNavigationProfileIcon extends StatelessWidget {
  const BottomNavigationProfileIcon({
    Key? key,
    required this.active,
    this.large = false,
    this.color,
  }) : super(key: key);

  final bool active;
  final bool large;
  final Color? color;

  IconData _icon(
    UserAvailabilityStatus status,
    bool isRingingDeviceOffline,
  ) =>
      isRingingDeviceOffline
          ? FontAwesomeIcons.exclamation
          : switch (status) {
              UserAvailabilityStatus.online => FontAwesomeIcons.solidCheck,
              UserAvailabilityStatus.availableForColleagues =>
                FontAwesomeIcons.solidArrowRightArrowLeft,
              UserAvailabilityStatus.doNotDisturb =>
                FontAwesomeIcons.solidBellSlash,
              UserAvailabilityStatus.offline => FontAwesomeIcons.solidMinus,
            };

  Color _color(
    BuildContext context,
    UserAvailabilityStatus status,
    bool isRingingDeviceOffline,
  ) =>
      isRingingDeviceOffline
          ? context.brand.theme.colors.red1
          : switch (status) {
              UserAvailabilityStatus.doNotDisturb =>
                context.brand.theme.colors.userAvailabilityUnavailableIcon,
              UserAvailabilityStatus.offline =>
                context.brand.theme.colors.userAvailabilityOffline,
              UserAvailabilityStatus.online ||
              UserAvailabilityStatus.availableForColleagues =>
                context.brand.theme.colors.green1,
            };

  @override
  Widget build(BuildContext context) {
    return UserAvailabilityStatusBuilder(
      builder: (context, status, isRingingDeviceOffline) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FaIcon(
              active
                  ? FontAwesomeIcons.solidCircleUser
                  : FontAwesomeIcons.circleUser,
              size: large ? 36 : null,
              color: color,
            ),
            Positioned(
              right: -4,
              bottom: -2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _color(context, status, isRingingDeviceOffline),
                ),
                constraints: BoxConstraints(
                  minWidth: large ? 16 : 12,
                  minHeight: large ? 16 : 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: FaIcon(
                      _icon(status, isRingingDeviceOffline),
                      color: Colors.white,
                      size: large ? 10 : 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
