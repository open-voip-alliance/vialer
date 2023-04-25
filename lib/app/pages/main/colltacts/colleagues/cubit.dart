import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/colltacts/colltact_tab.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/legacy/storage.dart';
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

class ColleaguesCubit extends Cubit<ColleaguesState> {
  final _storageRepository = dependencyLocator<StorageRepository>();

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
    _changeSetting(AppSetting.showOnlineColleaguesOnly, value);
  }

  ColleaguesCubit(this._caller)
      : super(const ColleaguesState.loading(
          showOnlineColleaguesOnly: false,
        )) {
    _eventBus.on<UserWasLoggedOutEvent>((event) {
      disconnectFromWebSocket(purgeCache: true);
    });
  }

  Future<void> connectToWebSocket({bool fullRefresh = false}) async {
    if (!_shouldShowColleagues() || _subscription != null) return;

    final lastKnownCollegues = _colleagues;

    emit(
      ColleaguesState.loading(
        showOnlineColleaguesOnly: showOnlineColleaguesOnly,
      ),
    );

    final stream = await _receiveColleagueAvailability(
      forceFullAvailabilityRefresh: fullRefresh,
    );

    _subscription =
        stream.debounceTime(const Duration(milliseconds: 50)).listen(
              (colleagues) {
                // Emitting loading initially to ensure listeners receive
                // the new state.
                emit(
                  ColleaguesState.loading(
                    showOnlineColleaguesOnly: showOnlineColleaguesOnly,
                  ),
                );
                emit(
                  ColleaguesState.loaded(
                    colleagues,
                    showOnlineColleaguesOnly: showOnlineColleaguesOnly,
                  ),
                );
              },
              cancelOnError: false,
              onDone: () {
                emit(ColleaguesState.loaded(
                  lastKnownCollegues,
                  showOnlineColleaguesOnly: showOnlineColleaguesOnly,
                  upToDate: false,
                ));
              },
            );
  }

  Future<void> disconnectFromWebSocket({bool purgeCache = false}) async {
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

  ColltactTab getStoredTab() =>
      _storageRepository.currentColltactTab ?? ColltactTab.contacts;

  // ignore: use_setters_to_change_properties
  void storeCurrentTab(ColltactTab tab) {
    _storageRepository.currentColltactTab = tab;
  }
}
