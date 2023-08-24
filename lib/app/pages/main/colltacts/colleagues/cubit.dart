import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vialer/domain/authentication/user_logged_in.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../../dependency_locator.dart';
import '../../../../../domain/authentication/user_was_logged_out.dart';
import '../../../../../domain/event/event_bus.dart';
import '../../../../../domain/onboarding/is_onboarded.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../../domain/user/settings/app_setting.dart';
import '../../../../../domain/user/settings/change_setting.dart';
import '../../../../../domain/relations/colleagues/colleague.dart';
import '../../../../../domain/relations/colleagues/receive_colleague_availability.dart';
import '../../../../../domain/relations/colleagues/should_show_colleagues.dart';
import '../../../../../domain/relations/colleagues/stop_receiving_colleague_availability.dart';
import '../../../../../domain/voipgrid/user_permissions.dart';
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
        await disconnectFromWebSocket(purgeCache: true);
        close();
      })
      ..on<UserLoggedIn>(
        (_) => unawaited(connectToWebSocket(fullRefresh: true)),
      );
  }

  late final _shouldShowColleagues = ShouldShowColleagues();
  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();
  late final _stopReceivingColleagueAvailability =
      StopReceivingColleagueAvailability();
  final _eventBus = dependencyLocator<EventBusObserver>();
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

  bool get canViewColleagues =>
      _getUser().hasPermission(Permission.canViewColleagues);

  bool get showOnlineColleaguesOnly =>
      _getUser().settings.get(AppSetting.showOnlineColleaguesOnly);

  set showOnlineColleaguesOnly(bool value) {
    emit(state.copyWith(showOnlineColleaguesOnly: value));
    unawaited(_changeSetting(AppSetting.showOnlineColleaguesOnly, value));
  }

  bool get _isOnboarded => IsOnboarded()();

  Future<void> connectToWebSocket({bool fullRefresh = false}) async {
    if (!_isOnboarded || !_shouldShowColleagues() || _subscription != null) {
      return;
    }

    final lastKnownColleagues = _colleagues;

    emit(
      ColleaguesState.loading(
        showOnlineColleaguesOnly: showOnlineColleaguesOnly,
      ),
    );

    final stream = _receiveColleagueAvailability(
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
                emit(
                  ColleaguesState.loaded(
                    lastKnownColleagues,
                    showOnlineColleaguesOnly: showOnlineColleaguesOnly,
                    upToDate: false,
                  ),
                );
              },
            );
  }

  Future<void> disconnectFromWebSocket({bool purgeCache = false}) =>
      _stopReceivingColleagueAvailability(purgeCache: purgeCache);

  /// Refresh the WebSocket, disconnecting and reconnecting to load all
  /// new data.
  ///
  /// This should only be called on a specific user-action as it has a large
  /// amount of overhead.
  Future<void> refresh() async {
    await disconnectFromWebSocket();
    await connectToWebSocket(fullRefresh: true);
  }

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.colleagues);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await super.close();
  }
}
