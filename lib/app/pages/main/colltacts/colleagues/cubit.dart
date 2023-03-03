import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/metrics/track_colleague_tab_selected.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/settings/app_setting.dart';
import '../../../../../domain/user/settings/change_setting.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../../domain/user_availability/colleagues/receive_colleague_availability.dart';
import '../../../../../domain/user_availability/colleagues/should_show_colleagues.dart';
import '../../../../../domain/user_availability/colleagues/stop_receiving_colleague_availability.dart';
import '../../widgets/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class ColleagueCubit extends Cubit<ColleagueState> {
  late final _shouldShowColleagues = ShouldShowColleagues();
  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();
  late final _stopReceivingColleagueAvailability =
      StopReceivingColleagueAvailability();
  final _eventBus = dependencyLocator<EventBusObserver>();
  final _getUser = GetLoggedInUserUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _trackColleagueTabSelected = TrackColleagueTabSelectedUseCase();

  final CallerCubit _caller;

  StreamSubscription? _subscription;

  List<Colleague> get _colleagues => state.when(
        loading: () => [],
        unreachable: () => [],
        loaded: (colleagues) => colleagues,
      );

  List<Colleague> get _filteredColleagues => showOnlineColleaguesOnly
      ? _colleagues.filter((colleague) => colleague.isOnline).toList()
      : _colleagues;

  bool get shouldShowColleagues =>
      _shouldShowColleagues() &&
      (_colleagues.isNotEmpty ||
          state is LoadingColleagues ||
          state is WebSocketUnreachable);

  bool get canViewColleagues => _getUser().permissions.canViewColleagues;

  /// Storing the value locally so we don't have to deal with delay when
  /// changing the value.
  bool? _transientShowOnlineColleaguesOnly;

  bool get showOnlineColleaguesOnly =>
      _transientShowOnlineColleaguesOnly ??
      _getUser().settings.get(AppSetting.showOnlineColleaguesOnly);

  set showOnlineColleaguesOnly(bool value) {
    _transientShowOnlineColleaguesOnly = value;
    loadColleagues();
    _changeSetting(AppSetting.showOnlineColleaguesOnly, value);
  }

  ColleagueCubit(this._caller) : super(const ColleagueState.loading()) {
    _eventBus.on<UserWasLoggedOutEvent>((event) {
      disconnectFromWebSocket(purgeCache: true);
    });

    //wip
    // // Check the initial state as there may already be some colleagues loaded. //wip
    // state.when(
    //   loading: () => null,
    //   unreachable: () => null,
    //   loaded:
    //       _handleColleaguesUpdate,
    // );

    stream.listen(
      (event) => event.when(
        loading: () => null,
        unreachable: () => null,
        loaded:
            _handleColleaguesUpdate, //wip just emit here and remove the method
      ),
    );
  }

  //wip do we even need this function?
  void _handleColleaguesUpdate(List<Colleague> colleagues) {
    // final state = this.state;

    // We want to replace all the colleagues
    // final colltacts = _filteredColleagues.map(Colltact.colleague).toList()
    //   ..addAll(state.colltacts.contacts);

    // emit(state.copyWith(colltacts: colltacts)); //wip
    emit(ColleagueState.loaded(_filteredColleagues));
  }

  Future<void> loadColleagues() async {
    // final state = this.state;
    //
    // if (state is! ColleaguesLoaded) {
    //   emit(const ColleagueState.loading());
    // }
    //
    // emit(
    //   ColleagueState.loaded(_filteredColleagues),
    // );

    connectToWebSocket(); //wip
  }

  Future<void> connectToWebSocket({bool fullRefresh = false}) async {
    if (!_shouldShowColleagues() || _subscription != null) return;

    emit(const ColleagueState.loading());

    final stream = await _receiveColleagueAvailability(
      forceFullAvailabilityRefresh: fullRefresh,
    );

    _subscription =
        stream.debounceTime(const Duration(milliseconds: 250)).listen(
      (colleagues) {
        // Emitting loading initially to ensure listeners receive the new state.
        emit(const ColleagueState.loading());
        emit(ColleagueState.loaded(colleagues));
      },
      onDone: () {
        _subscription?.cancel();
        _subscription = null;
        emit(const ColleagueState.unreachable());
      },
    );
  }

  Future<void> disconnectFromWebSocket({bool purgeCache = false}) async {
    _subscription?.cancel();
    _subscription = null;
    _stopReceivingColleagueAvailability(purgeCache: purgeCache);
  }

  /// Refresh the WebSocket, disconnecting and reconnecting to load all
  /// new data.
  ///
  /// This should only be called on a specific user-action as it has a large
  /// amount of overhead.
  Future<void> refresh() async {
    await disconnectFromWebSocket();
    connectToWebSocket(fullRefresh: true);
  }

  void trackColleaguesTabSelected() => _trackColleagueTabSelected();

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.colleagues);
}
