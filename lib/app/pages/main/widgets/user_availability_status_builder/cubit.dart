import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/user/events/logged_in_user_dnd_status_changed.dart';
import 'package:vialer/domain/user_availability/colleagues/availbility_update.dart';
import 'package:vialer/domain/user_availability/colleagues/colleague.dart';
import 'package:vialer/domain/user_availability/colleagues/colleagues_repository.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/calling/voip/destination.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/events/logged_in_user_was_refreshed.dart';
import '../../../../../domain/user/get_stored_user.dart';
import '../../../../../domain/user/settings/call_setting.dart';
import '../../../../../domain/user/user.dart';
import 'state.dart';

export 'state.dart';

class UserAvailabilityStatusCubit extends Cubit<UserAvailabilityStatusState> {
  UserAvailabilityStatusCubit()
      : super(
          UserAvailabilityStatusState(
            status: ColleagueAvailabilityStatus.offline,
          ),
        ) {
    _eventBus
      ..on<LoggedInUserDndStatusChanged>((_) => unawaited(check()))
      ..on<LoggedInUserAvailabilityChanged>(
        (event) => unawaited(check(event.availability)),
      )
      ..on<LoggedInUserWasRefreshed>((_) => unawaited(check()));
  }

  late final _eventBus = dependencyLocator<EventBusObserver>();
  late final _colleagueRepository = dependencyLocator<ColleaguesRepository>();
  User? get _user => GetStoredUserUseCase()();

  Future<void> check([AvailabilityUpdate? availability]) async {
    if (availability != null && HasFeature()(Feature.userBasedDnd)) {
      emit(
        UserAvailabilityStatusState(status: availability.availabilityStatus),
      );
    }

    if (!_colleagueRepository.isWebSocketConnected ||
        !HasFeature()(Feature.userBasedDnd)) {
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
