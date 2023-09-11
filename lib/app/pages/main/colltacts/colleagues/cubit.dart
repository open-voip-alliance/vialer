import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vialer/domain/legacy/storage.dart';
import 'package:vialer/domain/relations/colleagues/colleagues_repository.dart';
import 'package:vialer/domain/relations/websocket/events/user_availability_changed.dart';
import 'package:vialer/domain/relations/websocket/relations_websocket.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/onboarding/is_onboarded.dart';
import '../../../../../domain/relations/user_availability_status.dart';
import '../../../../../domain/user/events/logged_in_user_availability_changed.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/settings/app_setting.dart';
import '../../../../../domain/user/settings/change_setting.dart';
import '../../../../../domain/relations/colleagues/colleague.dart';
import '../../../../../domain/relations/colleagues/should_show_colleagues.dart';
import '../../../../util/synchronized_task.dart';
import '../../widgets/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class ColleaguesCubit extends Cubit<ColleaguesState> {
  ColleaguesCubit(this._caller)
      : super(
          const ColleaguesState.loading(
            showOnlineColleaguesOnly: false,
          ),
        ) {
    _eventBus
      ..on<UserWasLoggedOutEvent>((_) async {
        emit(ColleaguesState.loading(
          showOnlineColleaguesOnly: state.showOnlineColleaguesOnly,
        ));
        _purgeCache();
        close();
      })
      ..debounceTime(const Duration(milliseconds: 50))
          .on<UserAvailabilityChangedPayload>(_colleaguesChanged);
  }

  late final _shouldShowColleagues = ShouldShowColleagues();
  final _eventBus = dependencyLocator<EventBusObserver>();
  final _websocket = dependencyLocator<RelationsWebsocket>();
  final _colleagueRepository = dependencyLocator<ColleaguesRepository>();
  final _storage = dependencyLocator<StorageRepository>();
  final _getUser = GetLoggedInUserUseCase();
  final _changeSetting = ChangeSettingUseCase();

  final CallerCubit _caller;

  StreamSubscription<List<Colleague>>? _subscription;

  List<Colleague> get _colleagues => state.map(
        loading: (_) => [],
        loaded: (state) => state.colleagues,
      );

  bool get shouldShowColleagues =>
      _shouldShowColleagues() &&
      (_colleagues.isNotEmpty || state is LoadingColleagues);

  bool get canViewColleagues => _getUser().permissions.canViewColleagues;

  bool get showOnlineColleaguesOnly =>
      _getUser().settings.get(AppSetting.showOnlineColleaguesOnly);

  set showOnlineColleaguesOnly(bool value) {
    emit(state.copyWith(showOnlineColleaguesOnly: value));
    unawaited(_changeSetting(AppSetting.showOnlineColleaguesOnly, value));
  }

  bool get _isOnboarded => IsOnboarded()();

  Future<void> _colleaguesChanged(UserAvailabilityChangedPayload event) async {
    final user = _getUser();

    // We are going to hijack this WebSocket and emit an event when we
    // know our user has changed on the server.
    if (event.userUuid == user.uuid) {
      dependencyLocator<EventBus>().broadcast(
        LoggedInUserAvailabilityChanged(
          availability: event,
          userAvailabilityStatus: event.toUserAvailabilityStatus(),
        ),
      );
    }

    if (!_isOnboarded || !_shouldShowColleagues()) return;

    final colleagues =
        state is LoadingColleagues ? await _fetchColleagues() : _colleagues;

    final colleague = colleagues.findByUserUuid(event.userUuid);

    // If no colleague is found, we can't update the availability of it.
    if (colleague == null) {
      return _updateColleagues(colleagues);
    }

    // We don't want to display colleagues that do not have linked
    // destinations as these are essentially inactive users that do not
    // have any possible availability status.
    if (!event.hasLinkedDestinations) {
      _updateColleagues(colleagues..remove(colleague));
      return;
    }

    colleagues.replace(
      original: colleague,
      replacement: colleague.populateWithAvailability(event),
    );

    _updateColleagues(colleagues);
  }

  void _updateColleagues(List<Colleague> colleagues) {
    emit(
      ColleaguesState.loaded(
        colleagues,
        showOnlineColleaguesOnly: state.showOnlineColleaguesOnly,
      ),
    );
  }

  Future<List<Colleague>> _fetchColleagues() async =>
      SynchronizedTask<List<Colleague>>.of(this).run(
        () async => _storage.colleagues =
            await _colleagueRepository.getColleagues(_getUser()),
      );

  /// Refresh the WebSocket, disconnecting and reconnecting to load all
  /// new data.
  ///
  /// This should only be called on a specific user-action as it has a large
  /// amount of overhead.
  Future<void> refresh() async {
    await _websocket.disconnect();
    _purgeCache();
    await _websocket.connect();
  }

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.colleagues);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await super.close();
  }

  /// Purge our locally stored cache, in this case in the cubit's state, so we
  /// dismiss stale data.
  void _purgeCache() => _updateColleagues([]);
}

extension on List<Colleague> {
  Colleague? findByUserUuid(String uuid) =>
      where((colleague) => colleague.id == uuid).firstOrNull;

  void replace({required Colleague original, required Colleague replacement}) {
    final index = indexOf(original);

    replaceRange(
      index,
      index + 1,
      [replacement],
    );
  }
}

extension on Colleague {
  Colleague populateWithAvailability(
    UserAvailabilityChangedPayload availability,
  ) =>
      map(
        (colleague) => colleague.copyWith(
          status: availability.availability,
          destination: ColleagueDestination(
            number: availability.internalNumber.toString(),
            type: availability.destinationType,
          ),
          context: availability.context,
        ),
        // We don't get availability updates for voip accounts so we will
        // just leave them as is.
        unconnectedVoipAccount: (voipAccount) => voipAccount,
      );
}

extension on UserAvailabilityChangedPayload {
  UserAvailabilityStatus toUserAvailabilityStatus() {
    if (destinationType == ColleagueDestinationType.voipAccount &&
        availability == ColleagueAvailabilityStatus.offline) {
      return UserAvailabilityStatus.onlineWithRingingDeviceOffline;
    }

    return switch (availability) {
      ColleagueAvailabilityStatus.available => UserAvailabilityStatus.online,
      ColleagueAvailabilityStatus.busy => UserAvailabilityStatus.online,
      ColleagueAvailabilityStatus.unknown => UserAvailabilityStatus.online,
      ColleagueAvailabilityStatus.offline => UserAvailabilityStatus.offline,
      ColleagueAvailabilityStatus.doNotDisturb =>
        UserAvailabilityStatus.doNotDisturb,
    };
  }
}
