import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/user.dart';
import '../../../../../domain/user_availability/colleagues/availbility_update.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../resources/theme.dart';
import '../../widgets/colltact_list/widgets/avatar.dart';

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
  final _eventBus = dependencyLocator<EventBusObserver>();
  var _userAvailabilityStatus = ColleagueAvailabilityStatus.available;
  String? _internalNumber;
  ColleagueContext? _colleagueContext;

  @override
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>((event) {
      if (mounted) {
        setState(() {
          _internalNumber = event.availability.internalNumber;
          _userAvailabilityStatus =
              event.availability.asLoggedInUserDisplayStatus();
        });
      }
    });
  }

  String get _subheading => _internalNumber.isNotNullOrBlank
      ? '$_internalNumber - ${widget.user.email}'
      : widget.user.email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Row(
        children: [
          UserAvatar(
            relevantContext: _colleagueContext,
            status: _userAvailabilityStatus,
            icon: FontAwesomeIcons.solidCircleUser,
          ),
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
