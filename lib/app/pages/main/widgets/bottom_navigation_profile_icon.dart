import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/widgets/user_availability_status_builder.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';
import 'package:vialer/domain/user_availability/colleagues/colleague.dart';
import '../../../resources/theme.dart';

class BottomNavigationProfileIcon extends StatefulWidget {
  const BottomNavigationProfileIcon({
    Key? key,
    required this.active,
  }) : super(key: key);

  final bool active;

  @override
  State<BottomNavigationProfileIcon> createState() =>
      _BottomNavigationProfileIconState();
}

class _BottomNavigationProfileIconState
    extends State<BottomNavigationProfileIcon> {
  final _getUser = GetLoggedInUserUseCase();

  IconData _icon(ColleagueAvailabilityStatus status) => switch (status) {
        ColleagueAvailabilityStatus.doNotDisturb =>
          FontAwesomeIcons.solidBellSlash,
        ColleagueAvailabilityStatus.offline => FontAwesomeIcons.solidMinus,
        _ => FontAwesomeIcons.solidCheck,
      };

  Color _color(ColleagueAvailabilityStatus status) => switch (status) {
        ColleagueAvailabilityStatus.doNotDisturb =>
          context.brand.theme.colors.userAvailabilityUnavailableIcon,
        ColleagueAvailabilityStatus.offline =>
          context.brand.theme.colors.userAvailabilityOffline,
        _ => context.brand.theme.colors.green1,
      };

  @override
  Widget build(BuildContext context) {
    return UserAvailabilityStatusBuilder(
      builder: (context, status) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Badge(
            backgroundColor: _color(status),
            offset: Offset(6, 4),
            alignment: AlignmentDirectional.bottomEnd,
            label: FaIcon(
              _icon(status),
              color: Colors.white,
              size: 8,
            ),
            child: FaIcon(
              widget.active
                  ? FontAwesomeIcons.solidCircleUser
                  : FontAwesomeIcons.circleUser,
            ),
          ),
        );
      },
      user: _getUser(),
    );
  }
}
