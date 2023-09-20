import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/cubit.dart';
import 'package:vialer/domain/relations/colleagues/colleague.dart';
import 'package:vialer/domain/relations/colleagues/colleagues_repository.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/calling/voip/destination.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/relations/user_availability_status.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/events/logged_in_user_was_refreshed.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/get_stored_user.dart';
import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../../domain/user/settings/settings.dart';
import '../../../../../domain/user/user.dart';
import '../../settings/availability/ringing_device/widget.dart';
import 'state.dart';

export 'state.dart';

class UserAvailabilityStatusCubit extends Cubit<UserAvailabilityStatusState> {
  UserAvailabilityStatusCubit(this._settingsCubit)
      : super(
          UserAvailabilityStatusState(
            status:
                ColleagueAvailabilityStatus.offline.toUserAvailabilityStatus(),
          ),
        ) {
    _eventBus
      ..on<LoggedInUserAvailabilityChanged>(
        (event) => unawaited(check(availability: event.userAvailabilityStatus)),
      )
      ..on<LoggedInUserWasRefreshed>((_) => unawaited(check()));
  }

  final SettingsCubit _settingsCubit;
  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _colleagueRepository = dependencyLocator<ColleaguesRepository>();
  User? get _user => GetStoredUserUseCase()();

  Future<void> changeAvailabilityStatus(
    UserAvailabilityStatus requestedStatus,
    List<Destination> destinations,
  ) async {
    requestedStatus = requestedStatus.basic;
    check();

    final user = GetLoggedInUserUseCase()();

    await _settingsCubit.changeSettings(
      _determineSettingsToModify(user, destinations, requestedStatus),
    );

    check();
  }

  Map<SettingKey, Object> _determineSettingsToModify(
    User user,
    List<Destination> destinations,
    UserAvailabilityStatus requestedStatus,
  ) {
    final destination =
        destinations.findHighestPriorityDestinationFor(user: user);

    // We still need to make sure a user gets a ringing device when they are
    // coming from offline, otherwise pressing "available" would not make
    // them available.
    final shouldChangeOnAvailable =
        destination != null && user.ringingDevice == RingingDeviceType.unknown;

    // We never want enabling dnd to change the ringing device when using the
    // new dnd api. It's still required for the legacy dnd but should be removed
    // when possible.
    final shouldChangeOnDnd =
        destination != null && user.currentDestination is NotAvailable;

    return switch (requestedStatus) {
      UserAvailabilityStatus.online => {
          CallSetting.dnd: false,
          if (shouldChangeOnAvailable) CallSetting.destination: destination,
        },
      UserAvailabilityStatus.doNotDisturb => {
          CallSetting.dnd: true,
          if (shouldChangeOnDnd) CallSetting.destination: destination,
        },
      UserAvailabilityStatus.offline => {
          CallSetting.destination: const Destination.notAvailable(),
          CallSetting.dnd: false,
        },
      _ => throw ArgumentError(
          'Only [available], [doNotDisturb], [offline] '
          'are valid options for setting user status.',
        ),
    };
  }

  Future<void> check({
    UserAvailabilityStatus? availability,
  }) async {
    final destination = _user?.currentDestination;

    if (availability != null) {
      return emit(state.copyWith(
        status: availability,
        currentDestination: destination,
      ));
    }

    // If the websocket can't connect we're just going to fallback to
    // determining the status based on what we have stored locally. This is
    // usually accurate, but not necessarily.
    if (!_colleagueRepository.isWebSocketConnected) {
      return emit(state.copyWith(
        status: _status,
        currentDestination: destination,
      ));
    }

    // We don't have any availability update, so we'll just make sure to emit
    // the new state with the current destination.
    emit(state.copyWith(currentDestination: destination));
  }

  // This is only used while we are using legacy do-not-disturb, or the
  // websocket is unavailable. Otherwise we should always be using the value
  // directly from the websocket.
  UserAvailabilityStatus get _status {
    final user = _user;

    if (user == null) return UserAvailabilityStatus.offline;

    final destination = user.settings.getOrNull(CallSetting.destination);
    final isDndEnabled = user.settings.getOrNull(CallSetting.dnd) ?? false;

    if (destination is NotAvailable) return UserAvailabilityStatus.offline;

    return isDndEnabled
        ? UserAvailabilityStatus.doNotDisturb
        : UserAvailabilityStatus.online;
  }
}

extension on ColleagueAvailabilityStatus {
  UserAvailabilityStatus toUserAvailabilityStatus() => switch (this) {
        ColleagueAvailabilityStatus.available => UserAvailabilityStatus.online,
        ColleagueAvailabilityStatus.offline => UserAvailabilityStatus.offline,
        ColleagueAvailabilityStatus.doNotDisturb =>
          UserAvailabilityStatus.doNotDisturb,
        _ => UserAvailabilityStatus.online,
      };
}
