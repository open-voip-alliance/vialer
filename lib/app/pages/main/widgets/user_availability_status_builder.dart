import 'package:flutter/widgets.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';
import 'package:vialer/domain/user/settings/setting_changed.dart';

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
  }) : super(key: key);

  final UserAvailabilityStatusBuild builder;

  @override
  State<UserAvailabilityStatusBuilder> createState() =>
      _UserAvailabilityStatusBuilderState();
}

class _UserAvailabilityStatusBuilderState
    extends State<UserAvailabilityStatusBuilder> {
  final _eventBus = dependencyLocator<EventBusObserver>();

  ColleagueAvailabilityStatus get _status {
    final user = GetLoggedInUserUseCase()();
    final destination = user.settings.getOrNull(CallSetting.destination);
    final isDndEnabled = user.settings.getOrNull(CallSetting.dnd) ?? false;

    if (destination is NotAvailable) return ColleagueAvailabilityStatus.offline;

    return isDndEnabled
        ? ColleagueAvailabilityStatus.doNotDisturb
        : ColleagueAvailabilityStatus.available;
  }

  @override
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>((_) {
      setState(() {});
    });

    _eventBus.on<SettingChangedEvent>((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _status,
    );
  }
}
