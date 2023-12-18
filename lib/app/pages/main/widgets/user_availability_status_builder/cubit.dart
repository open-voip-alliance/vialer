import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/cubit.dart';
import 'package:vialer/domain/calling/voip/destination_repository.dart';
import 'package:vialer/domain/user/events/user_devices_changed.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/calling/voip/destination.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/relations/availability/availability_status_repository.dart';
import '../../../../../domain/relations/user_availability_status.dart';
import '../../../../../domain/relations/websocket/relations_web_socket.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/events/logged_in_user_was_refreshed.dart';
import '../../../../../domain/user/get_stored_user.dart';
import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../../domain/user/user.dart';
import '../../settings/availability/ringing_device/widget.dart';
import 'state.dart';

export 'state.dart';

class UserAvailabilityStatusCubit extends Cubit<UserAvailabilityStatusState> {
  UserAvailabilityStatusCubit(this._settingsCubit)
      : super(UserAvailabilityStatusState(UserAvailabilityStatus.offline)) {
    _eventBus
      ..on<LoggedInUserAvailabilityChanged>(
        (event) => unawaited(
          check(
            availability: event.userAvailabilityStatus,
            isRingingDeviceOffline: event.isRingingDeviceOffline,
          ),
        ),
      )
      ..on<LoggedInUserWasRefreshed>((_) => unawaited(check()))
      ..on<UserDevicesChanged>((_) => unawaited(check()));
  }

  final SettingsCubit _settingsCubit;
  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _relationsWebSocket = dependencyLocator<RelationsWebSocket>();
  late final _destinations = dependencyLocator<DestinationRepository>();
  late final _availabilityStatusRepository =
      dependencyLocator<UserAvailabilityStatusRepository>();
  User? get _user => GetStoredUserUseCase()();

  Future<void> changeAvailabilityStatus(
    UserAvailabilityStatus requestedStatus,
    List<Destination> destinations,
  ) async {
    check();

    final result = await _settingsCubit.changeSetting(
      CallSetting.availabilityStatus,
      requestedStatus,
    );

    check(availability: result.wasChanged ? requestedStatus : null);
  }

  Future<void> check({
    UserAvailabilityStatus? availability,
    bool isRingingDeviceOffline = false,
  }) async {
    final destination = _user?.currentDestination;
    final availableDestinations = _destinations.availableDestinations;

    // If the websocket is offline we're going to fetch this value from the api.
    if (!_relationsWebSocket.isWebSocketConnected) {
      availability = await _fetchStatusFromServer();
    }

    if (availability != null) {
      return emit(state.copyWith(
        status: availability,
        currentDestination: destination,
        availableDestinations: availableDestinations,
        isRingingDeviceOffline: isRingingDeviceOffline,
      ));
    }

    // If the websocket can't connect we're just going to fallback to
    // determining the status based on what we have stored locally. This is
    // usually accurate, but not necessarily.
    if (!_relationsWebSocket.isWebSocketConnected) {
      return emit(state.copyWith(
        status: _status,
        currentDestination: destination,
        availableDestinations: availableDestinations,
      ));
    }

    // We don't have any availability update, so we'll just make sure to emit
    // the new state with the current destination.
    emit(state.copyWith(
      currentDestination: destination,
      availableDestinations: availableDestinations,
    ));
  }

  Future<UserAvailabilityStatus> _fetchStatusFromServer() =>
      _availabilityStatusRepository.getAvailabilityStatus(
        GetLoggedInUserUseCase()(),
      );

  // This is only used while we are using legacy do-not-disturb, or the
  // websocket is unavailable. Otherwise we should always be using the value
  // directly from the websocket.
  UserAvailabilityStatus get _status {
    final user = _user;

    if (user == null) return UserAvailabilityStatus.offline;

    return user.settings.get(CallSetting.availabilityStatus);
  }
}
