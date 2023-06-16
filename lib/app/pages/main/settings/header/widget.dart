import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/widgets/user_availability_status_builder/widget.dart';

import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/user.dart';
import '../../../../../domain/user_availability/colleagues/availbility_update.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../resources/theme.dart';
import '../../../../util/event_bus_listener.dart';

class Header extends StatefulWidget {
  const Header({
    required this.user,
    super.key,
  });

  final User user;

  @override
  State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String? _internalNumber;

  String get _subheading => _internalNumber.isNotNullOrBlank
      ? '$_internalNumber - ${widget.user.email}'
      : widget.user.email;

  @override
  Widget build(BuildContext context) {
    return EventBusListener<LoggedInUserAvailabilityChanged>(
      listener: (event) => setState(
        () => _internalNumber = event.availability.internalNumber,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        child: Row(
          children: [
            _UserStatusHeaderAvatar(),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.brand.theme.colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    _subheading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.brand.theme.colors.grey6,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension UserAvailabilityStatus on AvailabilityUpdate {
  ColleagueAvailabilityStatus asLoggedInUserDisplayStatus() {
    if (destination.type == ColleagueDestinationType.none) {
      return ColleagueAvailabilityStatus.offline;
    }

    // We only want to show a couple of statuses because we know this user
    // is online if they have the app open, no matter what the WebSocket says.
    return const [
      ColleagueAvailabilityStatus.available,
      ColleagueAvailabilityStatus.doNotDisturb,
      ColleagueAvailabilityStatus.busy,
    ].contains(availabilityStatus)
        ? availabilityStatus
        : ColleagueAvailabilityStatus.available;
  }
}

class _UserStatusHeaderAvatar extends StatelessWidget {
  const _UserStatusHeaderAvatar({
    Key? key,
  }) : super(key: key);

  Color _color(
    BuildContext context,
    ColleagueAvailabilityStatus status,
  ) =>
      switch (status) {
        ColleagueAvailabilityStatus.doNotDisturb =>
          context.brand.theme.colors.userAvailabilityBusyAvatar,
        ColleagueAvailabilityStatus.offline =>
          context.brand.theme.colors.userAvailabilityOffline,
        _ => context.brand.theme.colors.userAvailabilityAvailableAvatar,
      };

  @override
  Widget build(BuildContext context) {
    return UserAvailabilityStatusBuilder(
      builder: (context, status) {
        return FaIcon(
          FontAwesomeIcons.solidCircleUser,
          color: _color(context, status),
          size: 38,
        );
      },
    );
  }
}
