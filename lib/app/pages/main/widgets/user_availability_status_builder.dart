import 'package:flutter/widgets.dart';
import 'package:vialer/app/util/set_state_when_mounted.dart';
import 'package:vialer/domain/user/settings/setting_changed.dart';

import '../../../../dependency_locator.dart';
import '../../../../domain/calling/voip/destination.dart';
import '../../../../domain/event/event_bus.dart';
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
  final _eventBus = dependencyLocator<EventBusObserver>();
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
  void initState() {
    super.initState();
    _eventBus.on<LoggedInUserAvailabilityChanged>((_) {
      setStateWhenMounted(() {});
    });

    _eventBus.on<SettingChangedEvent>((_) {
      setStateWhenMounted(() {});
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
