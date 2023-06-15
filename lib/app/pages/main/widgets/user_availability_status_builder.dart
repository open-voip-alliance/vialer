import 'package:flutter/widgets.dart';
import 'package:vialer/app/util/event_bus_listener.dart';
import 'package:vialer/domain/user/settings/setting_changed.dart';

import '../../../../domain/calling/voip/destination.dart';
import '../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../domain/user/get_stored_user.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/user.dart';
import '../../../../domain/user_availability/colleagues/colleague.dart';

typedef UserAvailabilityStatusBuild = Widget Function(
  BuildContext context,
  ColleagueAvailabilityStatus status,
);

class UserAvailabilityStatusBuilder extends StatefulWidget {
  const UserAvailabilityStatusBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final UserAvailabilityStatusBuild builder;

  @override
  State<UserAvailabilityStatusBuilder> createState() =>
      _UserAvailabilityStatusBuilderState();
}

class _UserAvailabilityStatusBuilderState
    extends State<UserAvailabilityStatusBuilder> {
  // We're having to use this instead of [GetLoggedInUserUseCase] because this
  // can receive events after the user has logged out, resulting in an error
  // as the user no longer exists.
  User? get _user => GetStoredUserUseCase()();

  ColleagueAvailabilityStatus get _status {
    final user = _user;

    if (user == null) return ColleagueAvailabilityStatus.offline;

    final destination = user.settings.getOrNull(CallSetting.destination);
    final isDndEnabled = user.settings.getOrNull(CallSetting.dnd) ?? false;

    if (destination is NotAvailable) return ColleagueAvailabilityStatus.offline;

    return isDndEnabled
        ? ColleagueAvailabilityStatus.doNotDisturb
        : ColleagueAvailabilityStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return EventBusListener<SettingChangedEvent>(
      listener: rebuildOnEvent,
      child: EventBusListener<LoggedInUserAvailabilityChanged>(
        listener: rebuildOnEvent,
        child: widget.builder(context, _status),
      ),
    );
  }
}
