import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/user.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../resources/theme.dart';
import '../../widgets/colltact_list/widgets/avatar.dart';

class Header extends StatefulWidget {
  final User user;

  const Header({required this.user});

  @override
  State<StatefulWidget> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  var _availabilityStatus = ColleagueAvailabilityStatus.available;
  String? _internalNumber;
  ColleagueContext? _colleagueContext;
  ColleagueDestination? _destination;

  @override
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>((event) {
      setState(() {
        _availabilityStatus = event.availabilityStatus;
        _internalNumber = event.internalNumber;
        _destination = event.destination;
      });
    });
  }

  String _subheading() => _internalNumber.isNotNullOrBlank
      ? '$_internalNumber - ${widget.user.email}'
      : widget.user.email;

  ColleagueAvailabilityStatus get _cleanedStatus {
    final validStatuses = [
      ColleagueAvailabilityStatus.available,
      ColleagueAvailabilityStatus.doNotDisturb,
      ColleagueAvailabilityStatus.busy,
    ];

    if (_destination?.type == ColleagueDestinationType.none) {
      return ColleagueAvailabilityStatus.offline;
    }

    // We only want to show a couple of statuses because we know this user
    // is online if they have the app open, no matter what the WebSocket says.
    return validStatuses.contains(_availabilityStatus)
        ? _availabilityStatus
        : ColleagueAvailabilityStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ).copyWith(
        bottom: 16,
      ),
      child: Row(
        children: [
          UserAvatar(
            relevantContext: _colleagueContext,
            status: _cleanedStatus,
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
                  _subheading(),
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
