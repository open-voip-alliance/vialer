import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/cubit.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';
import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/user_availability/colleagues/colleague.dart';
import 'package:vialer/domain/user_availability/colleagues/colleagues_repository.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/calling/voip/destination.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/events/logged_in_user_was_refreshed.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/get_stored_user.dart';
import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../../domain/user/settings/settings.dart';
import '../../../../../domain/user/user.dart';
import '../../../../../domain/user_availability/colleagues/availability_update.dart';
import 'state.dart';

export 'state.dart';

class UserAvailabilityStatusCubit extends Cubit<UserAvailabilityStatusState> {
  UserAvailabilityStatusCubit(this._settingsCubit)
      : super(
          UserAvailabilityStatusState(
            status: ColleagueAvailabilityStatus.offline,
          ),
        ) {
    _eventBus
      ..on<LoggedInUserAvailabilityChanged>(
        (event) => unawaited(check(availability: event.availability)),
      )
      ..on<LoggedInUserWasRefreshed>((_) => unawaited(check()));
  }

  final SettingsCubit _settingsCubit;
  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _colleagueRepository = dependencyLocator<ColleaguesRepository>();
  User? get _user => GetStoredUserUseCase()();

  /// We want the UI to be optimistic, rather than waiting for a server response
  /// before changing the status. We set this temporarily while making changes
  /// to immediately update the UI with the user's choice.
  ColleagueAvailabilityStatus? _statusOverride;

  Future<void> changeAvailabilityStatus(
    ColleagueAvailabilityStatus requestedStatus,
    List<Destination> destinations,
  ) async {
    _statusOverride = requestedStatus;
    check();

    final user = GetLoggedInUserUseCase()();

    await _settingsCubit.changeSettings(
      _determineSettingsToModify(user, destinations, requestedStatus),
    );

    if (!hasFeature(Feature.userBasedDnd)) {
      // Hacky solution to making sure availability doesn't sometimes flick back
      // to available. Should be removed with user-based dnd.
      // ignore: inference_failure_on_instance_creation
      await Future.delayed(const Duration(seconds: 1));
      await _settingsCubit.changeSetting(
        CallSetting.dnd,
        requestedStatus == ColleagueAvailabilityStatus.doNotDisturb,
      );
    }

    _statusOverride = null;
    check();
  }

  Map<SettingKey, Object> _determineSettingsToModify(
    User user,
    List<Destination> destinations,
    ColleagueAvailabilityStatus requestedStatus,
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
        destination != null && !hasFeature(Feature.userBasedDnd);

    return switch (requestedStatus) {
      ColleagueAvailabilityStatus.available => {
          CallSetting.dnd: false,
          if (shouldChangeOnAvailable) CallSetting.destination: destination,
        },
      ColleagueAvailabilityStatus.doNotDisturb => {
          CallSetting.dnd: true,
          if (shouldChangeOnDnd) CallSetting.destination: destination,
        },
      ColleagueAvailabilityStatus.offline => {
          CallSetting.dnd: false,
          CallSetting.destination: const Destination.notAvailable(),
        },
      _ => throw ArgumentError(
          'Only [available], [doNotDisturb], [offline] '
          'are valid options for setting user status.',
        ),
    };
  }

  Future<void> check({
    AvailabilityUpdate? availability,
  }) async {
    final override = _statusOverride;

    if (override != null) {
      emit(UserAvailabilityStatusState(status: override));
      return;
    }

    if (availability != null && hasFeature(Feature.userBasedDnd)) {
      emit(
        UserAvailabilityStatusState(status: availability.availabilityStatus),
      );
    }

    if (!_colleagueRepository.isWebSocketConnected ||
        !hasFeature(Feature.userBasedDnd)) {
      emit(UserAvailabilityStatusState(status: _status));
    }
  }

  // This is only used while we are using legacy do-not-disturb, or the
  // websocket is unavailable. Otherwise we should always be using the value
  // directly from the websocket.
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
}
