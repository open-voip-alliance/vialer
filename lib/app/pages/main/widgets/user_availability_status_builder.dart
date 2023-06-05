import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:vialer/app/pages/main/settings/header/widget.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/calling/voip/destination.dart';
import '../../../../domain/event/event_bus.dart';
import '../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user_availability/colleagues/colleague.dart';

typedef UserAvailabilityStatusBuild = Widget Function(
  BuildContext context,
  ColleagueAvailabilityStatus status,
);

class UserAvailabilityStatusBuilder extends StatefulWidget {
  const UserAvailabilityStatusBuilder({
    Key? key,
    required this.builder,
    required this.user,
  }) : super(key: key);

  final UserAvailabilityStatusBuild builder;
  final User user;

  @override
  State<UserAvailabilityStatusBuilder> createState() =>
      _UserAvailabilityStatusBuilderState();
}

class _UserAvailabilityStatusBuilderState
    extends State<UserAvailabilityStatusBuilder> {
  final _eventBus = dependencyLocator<EventBusObserver>();
  ColleagueAvailabilityStatus? _status;

  /// We get the [ColleagueAvailabilityStatus] from a websocket, if this
  /// websocket is down or not available we'll use this fallback instead at the
  /// expense of accuracy.
  ColleagueAvailabilityStatus _fallbackAvailabilityStatus(User user) {
    if (user.settings.getOrNull(CallSetting.dnd) ?? false) {
      return ColleagueAvailabilityStatus.doNotDisturb;
    }

    final destination = user.settings.getOrNull(CallSetting.destination);

    return destination is NotAvailable
        ? ColleagueAvailabilityStatus.offline
        : ColleagueAvailabilityStatus.available;
  }

  @override
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>(
      (event) {
        if (mounted) {
          setState(() {
            _status = event.availability.asLoggedInUserDisplayStatus();
          });
          return;
        }

        // This is a hacky solution to make it so the user's availability
        // does not switch back while we're in the process of updating it. This
        // can be removed when DND is user-based in the near future.
        _status = event.availability.asLoggedInUserDisplayStatus();

        Timer(const Duration(seconds: 3), () {
          setState(() {});
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _status ?? _fallbackAvailabilityStatus(widget.user),
    );
  }
}
